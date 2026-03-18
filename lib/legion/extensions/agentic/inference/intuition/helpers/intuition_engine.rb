# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Intuition
          module Helpers
            class IntuitionEngine
              include Constants

              attr_reader :patterns, :heuristics, :history

              def initialize
                @patterns       = {}
                @heuristics     = {}
                @pattern_count  = 0
                @heuristic_count = 0
                @history = []
              end

              def learn_pattern(cue:, response:, domain: :general, strength: DEFAULT_CONFIDENCE)
                return nil if @patterns.size >= MAX_PATTERNS

                @pattern_count += 1
                pattern = Pattern.new(
                  id:       :"pat_#{@pattern_count}",
                  cue:      cue,
                  response: response,
                  domain:   domain,
                  strength: strength
                )
                @patterns[pattern.id] = pattern
                record_event(:learn, pattern_id: pattern.id)
                pattern
              end

              def recognize(input_cue:, domain: nil)
                candidates = domain ? domain_patterns(domain) : @patterns.values
                matches = candidates.filter_map do |p|
                  score = p.match_score(input_cue)
                  { pattern: p, score: score } if score >= RECOGNITION_THRESHOLD
                end
                matches.sort_by { |m| -m[:score] }
              end

              def intuit(input_cue:, domain: nil)
                matches = recognize(input_cue: input_cue, domain: domain)
                return nil if matches.empty?

                best = matches.first
                record_event(:intuit, pattern_id: best[:pattern].id, score: best[:score])
                {
                  response:   best[:pattern].response,
                  pattern_id: best[:pattern].id,
                  confidence: best[:pattern].strength,
                  match:      best[:score],
                  mode:       intuition_mode(best)
                }
              end

              def reinforce_pattern(pattern_id:, success:)
                pattern = @patterns[pattern_id]
                return nil unless pattern

                pattern.reinforce(success: success)
                record_event(:reinforce, pattern_id: pattern_id, success: success)
                pattern.strength
              end

              def add_heuristic(name:, heuristic_type:, domain: :general)
                return nil if @heuristics.size >= MAX_HEURISTICS

                @heuristic_count += 1
                heuristic = Heuristic.new(
                  id:             :"heur_#{@heuristic_count}",
                  name:           name,
                  heuristic_type: heuristic_type,
                  domain:         domain
                )
                @heuristics[heuristic.id] = heuristic
                heuristic
              end

              def apply_heuristic(heuristic_id:)
                heuristic = @heuristics[heuristic_id]
                return nil unless heuristic

                heuristic.apply
                record_event(:apply_heuristic, heuristic_id: heuristic_id)
                heuristic.to_h
              end

              def record_heuristic_outcome(heuristic_id:, success:)
                heuristic = @heuristics[heuristic_id]
                return nil unless heuristic

                heuristic.record_outcome(success: success)
              end

              def reliable_patterns
                @patterns.values.select(&:reliable?).map(&:to_h)
              end

              def expert_patterns
                @patterns.values.select(&:expert?).map(&:to_h)
              end

              def effective_heuristics
                @heuristics.values.select(&:effective?).map(&:to_h)
              end

              def patterns_in(domain:)
                domain_patterns(domain).map(&:to_h)
              end

              def decay_all
                @patterns.each_value(&:decay)
              end

              def to_h
                {
                  pattern_count:             @patterns.size,
                  heuristic_count:           @heuristics.size,
                  reliable_pattern_count:    @patterns.values.count(&:reliable?),
                  expert_pattern_count:      @patterns.values.count(&:expert?),
                  effective_heuristic_count: @heuristics.values.count(&:effective?),
                  history_size:              @history.size
                }
              end

              private

              def domain_patterns(domain)
                @patterns.values.select { |p| p.domain == domain }
              end

              def intuition_mode(match)
                pattern = match[:pattern]
                return :compiled_expertise if pattern.expert?
                return :pattern_match if pattern.reliable?
                return :recognition_primed if match[:score] >= 0.8

                :gut_feeling
              end

              def record_event(type, **details)
                @history << { type: type, at: Time.now.utc }.merge(details)
                @history.shift while @history.size > MAX_HISTORY
              end
            end
          end
        end
      end
    end
  end
end

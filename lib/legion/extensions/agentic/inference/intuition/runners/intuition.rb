# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Intuition
          module Runners
            module Intuition
              include Helpers::Constants
              include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

              def learn_intuitive_pattern(cue:, response:, domain: :general, strength: DEFAULT_CONFIDENCE, **)
                pattern = engine.learn_pattern(cue: cue, response: response, domain: domain, strength: strength)
                return { success: false, reason: :limit_reached } unless pattern

                { success: true, pattern_id: pattern.id, strength: pattern.strength }
              end

              def intuitive_recognize(input_cue:, domain: nil, **)
                matches = engine.recognize(input_cue: input_cue, domain: domain)
                {
                  success: true,
                  matches: matches.map { |m| { pattern_id: m[:pattern].id, score: m[:score].round(4) } },
                  count:   matches.size
                }
              end

              def intuit_response(input_cue:, domain: nil, **)
                result = engine.intuit(input_cue: input_cue, domain: domain)
                return { success: false, reason: :no_match } unless result

                { success: true }.merge(result)
              end

              def reinforce_intuition(pattern_id:, success:, **)
                result = engine.reinforce_pattern(pattern_id: pattern_id, success: success)
                return { success: false, reason: :not_found } unless result

                { success: true, pattern_id: pattern_id, strength: result.round(4) }
              end

              def add_intuitive_heuristic(name:, heuristic_type:, domain: :general, **)
                heuristic = engine.add_heuristic(name: name, heuristic_type: heuristic_type, domain: domain)
                return { success: false, reason: :limit_reached } unless heuristic

                { success: true, heuristic_id: heuristic.id }
              end

              def apply_intuitive_heuristic(heuristic_id:, **)
                result = engine.apply_heuristic(heuristic_id: heuristic_id)
                return { success: false, reason: :not_found } unless result

                { success: true }.merge(result)
              end

              def reliable_intuitions(**)
                patterns = engine.reliable_patterns
                { success: true, patterns: patterns, count: patterns.size }
              end

              def expert_intuitions(**)
                patterns = engine.expert_patterns
                { success: true, patterns: patterns, count: patterns.size }
              end

              def update_intuition(**)
                engine.decay_all
                { success: true }.merge(engine.to_h)
              end

              def intuition_stats(**)
                { success: true }.merge(engine.to_h)
              end

              private

              def engine
                @engine ||= Helpers::IntuitionEngine.new
              end
            end
          end
        end
      end
    end
  end
end

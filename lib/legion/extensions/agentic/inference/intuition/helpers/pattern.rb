# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Intuition
          module Helpers
            class Pattern
              include Constants

              attr_reader :id, :cue, :domain, :response, :strength,
                          :encounters, :successes, :state

              def initialize(id:, cue:, response:, domain: :general, strength: DEFAULT_CONFIDENCE)
                @id         = id
                @cue        = cue
                @response   = response
                @domain     = domain
                @strength   = strength.to_f.clamp(CONFIDENCE_FLOOR, CONFIDENCE_CEILING)
                @encounters = 0
                @successes  = 0
                @state      = compute_state
              end

              def match_score(input_cue)
                return 0.0 unless input_cue.is_a?(Hash) && @cue.is_a?(Hash)

                shared = @cue.keys & input_cue.keys
                return 0.0 if shared.empty?

                matches = shared.count { |k| @cue[k] == input_cue[k] }
                matches.to_f / [@cue.size, input_cue.size].max
              end

              def recognized?(input_cue)
                match_score(input_cue) >= RECOGNITION_THRESHOLD
              end

              def reinforce(success:)
                @encounters += 1
                @successes += 1 if success
                shift = success ? REINFORCEMENT_RATE : -REINFORCEMENT_RATE
                @strength = (@strength + shift).clamp(CONFIDENCE_FLOOR, CONFIDENCE_CEILING)
                @state = compute_state
                @strength
              end

              def decay
                @strength = (@strength - DECAY_RATE).clamp(CONFIDENCE_FLOOR, CONFIDENCE_CEILING)
                @state = compute_state
              end

              def success_rate
                return 0.0 if @encounters.zero?

                @successes.to_f / @encounters
              end

              def reliable?
                @strength >= STATE_THRESHOLDS[:reliable] && @encounters >= 3
              end

              def expert?
                @strength >= STATE_THRESHOLDS[:expert] && @encounters >= 10
              end

              def confidence_label
                CONFIDENCE_LABELS.each { |range, lbl| return lbl if range.cover?(@strength) }
                :noise
              end

              def to_h
                {
                  id:               @id,
                  cue:              @cue,
                  response:         @response,
                  domain:           @domain,
                  strength:         @strength.round(4),
                  encounters:       @encounters,
                  successes:        @successes,
                  success_rate:     success_rate.round(4),
                  state:            @state,
                  confidence_label: confidence_label,
                  reliable:         reliable?,
                  expert:           expert?
                }
              end

              private

              def compute_state
                return :expert if @strength >= STATE_THRESHOLDS[:expert]
                return :reliable if @strength >= STATE_THRESHOLDS[:reliable]
                return :developing if @strength >= STATE_THRESHOLDS[:developing]

                :nascent
              end
            end
          end
        end
      end
    end
  end
end

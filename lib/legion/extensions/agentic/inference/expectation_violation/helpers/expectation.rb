# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module ExpectationViolation
          module Helpers
            class Expectation
              include Constants

              attr_reader :id, :context, :domain, :expected_value, :tolerance,
                          :violation_count, :adaptation_count, :created_at

              def initialize(context:, domain:, expected_value: DEFAULT_EXPECTATION, tolerance: 0.2)
                @id               = SecureRandom.uuid
                @context          = context
                @domain           = domain
                @expected_value   = expected_value.clamp(EXPECTATION_FLOOR, EXPECTATION_CEILING)
                @tolerance        = tolerance.clamp(0.01, 0.5)
                @violation_count  = 0
                @adaptation_count = 0
                @created_at       = Time.now.utc
              end

              def evaluate(actual_value:)
                deviation = actual_value - @expected_value
                violated = deviation.abs > @tolerance

                if violated
                  @violation_count += 1
                  arousal = compute_arousal(deviation)
                  violation_type = deviation.positive? ? :positive : :negative
                  { violated: true, deviation: deviation.round(3), type: violation_type,
                    arousal: arousal.round(3), arousal_label: arousal_label(arousal) }
                else
                  { violated: false, deviation: deviation.round(3), type: :neutral,
                    arousal: 0.0, arousal_label: :unaffected }
                end
              end

              def adapt!(actual_value:)
                @expected_value += (actual_value - @expected_value) * ADAPTATION_RATE
                @expected_value = @expected_value.clamp(EXPECTATION_FLOOR, EXPECTATION_CEILING)
                @adaptation_count += 1
              end

              def violation_label(deviation)
                VIOLATION_LABELS.find { |range, _| range.cover?(deviation) }&.last || :neutral
              end

              def to_h
                {
                  id:               @id,
                  context:          @context,
                  domain:           @domain,
                  expected_value:   @expected_value.round(3),
                  tolerance:        @tolerance,
                  violation_count:  @violation_count,
                  adaptation_count: @adaptation_count,
                  created_at:       @created_at
                }
              end

              private

              def compute_arousal(deviation)
                (AROUSAL_BASE + (deviation.abs * AROUSAL_MULTIPLIER)).clamp(0.0, 1.0)
              end

              def arousal_label(arousal)
                AROUSAL_LABELS.find { |range, _| range.cover?(arousal) }&.last || :moderate
              end
            end
          end
        end
      end
    end
  end
end

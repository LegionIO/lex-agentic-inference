# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module PredictiveProcessing
          module Helpers
            class GenerativeModel
              include Constants

              attr_reader :id, :domain, :confidence, :precision, :prediction_error, :state,
                          :last_prediction, :created_at, :updated_at

              def initialize(domain:)
                @id               = SecureRandom.uuid
                @domain           = domain
                @confidence       = DEFAULT_PRECISION
                @precision        = DEFAULT_PRECISION
                @prediction_error = 0.0
                @state            = :stable
                @history          = []
                @last_prediction  = nil
                @created_at       = Time.now.utc
                @updated_at       = Time.now.utc
              end

              def predict(context: {})
                richness     = context_richness(context)
                expected_val = (confidence + richness).clamp(0.0, 1.0)
                @last_prediction = {
                  expected_value: expected_val,
                  confidence:     confidence,
                  precision:      precision,
                  domain:         @domain,
                  context_size:   context.size,
                  predicted_at:   Time.now.utc
                }
              end

              def observe(actual:, predicted:)
                @prediction_error = compute_error(actual, predicted)
                update_history(@prediction_error)
                update_confidence
                update_state
                @updated_at = Time.now.utc
                @prediction_error
              end

              # Free energy (surprise): high when errors are large relative to precision.
              # Uses a formula that can exceed FREE_ENERGY_THRESHOLD (0.7) with sustained errors.
              def free_energy
                return 0.0 if @history.empty?

                recent    = @history.last(10)
                avg_error = recent.sum.to_f / recent.size
                raw       = avg_error * (1.5 - (precision * 0.5))
                raw.clamp(0.0, 1.0)
              end

              def update_model(error:)
                adjustment = error * LEARNING_RATE * precision
                @confidence = (@confidence - adjustment).clamp(MODEL_CONFIDENCE_FLOOR, 1.0)
                @state      = :updating
                @updated_at = Time.now.utc
              end

              def stable?
                free_energy <= FREE_ENERGY_THRESHOLD
              end

              def surprised?
                free_energy > FREE_ENERGY_THRESHOLD
              end

              def decay
                @precision = [@precision - PRECISION_DECAY, PRECISION_FLOOR].max
                @updated_at = Time.now.utc
              end

              def precision_label
                PRECISION_LABELS.find { |range, _label| range.cover?(precision) }&.last || :noise
              end

              def to_h
                {
                  id:               @id,
                  domain:           @domain,
                  confidence:       confidence,
                  precision:        precision,
                  prediction_error: @prediction_error,
                  free_energy:      free_energy,
                  state:            @state,
                  precision_label:  precision_label,
                  stable:           stable?,
                  surprised:        surprised?,
                  history_size:     @history.size,
                  created_at:       @created_at,
                  updated_at:       @updated_at
                }
              end

              private

              def context_richness(context)
                [context.size * 0.02, 0.2].min
              end

              def compute_error(actual, predicted)
                return 0.0 unless actual.is_a?(Numeric) && predicted.is_a?(Numeric)

                (actual - predicted).abs.clamp(0.0, 1.0)
              end

              def update_history(error)
                @history << error
                @history.shift while @history.size > MAX_HISTORY
              end

              def update_confidence
                delta = -@prediction_error * LEARNING_RATE
                @confidence = (@confidence + delta).clamp(MODEL_CONFIDENCE_FLOOR, 1.0)
              end

              def update_state
                @state = if surprised?
                           :surprised
                         elsif @history.size < 5
                           :exploring
                         else
                           :stable
                         end
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Prediction
          module Helpers
            class PredictionStore
              attr_reader :predictions, :outcomes

              def initialize
                @predictions = {}
                @outcomes = []
              end

              def store(prediction)
                id = prediction[:prediction_id] || SecureRandom.uuid
                prediction[:prediction_id] = id
                prediction[:created_at] ||= Time.now.utc
                prediction[:status] ||= :pending
                @predictions[id] = prediction
                id
              end

              def get(prediction_id)
                @predictions[prediction_id]
              end

              def resolve(prediction_id, outcome:, actual: nil)
                pred = @predictions[prediction_id]
                return nil unless pred

                pred[:status] = outcome # :correct, :incorrect, :partial, :expired
                pred[:resolved_at] = Time.now.utc
                pred[:actual] = actual

                @outcomes << { prediction_id: prediction_id, outcome: outcome, at: Time.now.utc }
                @outcomes.shift while @outcomes.size > 500
                pred
              end

              def pending
                @predictions.values.select { |p| p[:status] == :pending }
              end

              def accuracy(window: 100)
                recent = @outcomes.last(window)
                return 0.0 if recent.empty?

                correct = recent.count { |o| o[:outcome] == :correct }
                correct.to_f / recent.size
              end

              def count
                @predictions.size
              end

              def resolved_count
                @predictions.values.count { |p| p[:status] != :pending }
              end

              def recently_resolved(limit: 20)
                @outcomes.last(limit).filter_map do |entry|
                  pred = @predictions[entry[:prediction_id]]
                  next unless pred

                  {
                    prediction_id:  entry[:prediction_id],
                    domain:         pred[:mode],
                    outcome_domain: pred.dig(:context, :outcome_domain) || pred[:mode],
                    outcome:        entry[:outcome],
                    accurate:       entry[:outcome] == :correct,
                    confidence:     pred[:confidence],
                    resolved_at:    entry[:at]
                  }
                end
              end
            end
          end
        end
      end
    end
  end
end

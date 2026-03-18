# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Schema
          module Helpers
            class CausalRelation
              attr_reader :id, :cause, :effect, :relation_type, :confidence,
                          :evidence_count, :created_at, :updated_at

              def initialize(cause:, effect:, relation_type:, confidence: 0.5)
                @id             = SecureRandom.uuid
                @cause          = cause
                @effect         = effect
                @relation_type  = relation_type
                @confidence     = confidence.clamp(0.0, 1.0)
                @evidence_count = 1
                @created_at     = Time.now.utc
                @updated_at     = Time.now.utc
              end

              def reinforce(amount = Constants::REINFORCEMENT_BONUS)
                @confidence = [@confidence + amount, 1.0].min
                @evidence_count += 1
                @updated_at = Time.now.utc
              end

              def weaken(amount = Constants::CONTRADICTION_PENALTY)
                @confidence = [@confidence - amount, 0.0].max
                @updated_at = Time.now.utc
              end

              def decay
                @confidence = [@confidence - Constants::DECAY_RATE, 0.0].max
              end

              def established?
                @confidence >= Constants::CONFIDENCE_LEVELS[:established]
              end

              def speculative?
                @confidence <= Constants::CONFIDENCE_LEVELS[:speculative]
              end

              def prunable?
                @confidence < Constants::PRUNE_THRESHOLD
              end

              def to_h
                {
                  id:             @id,
                  cause:          @cause,
                  effect:         @effect,
                  relation_type:  @relation_type,
                  confidence:     @confidence.round(4),
                  evidence_count: @evidence_count,
                  established:    established?
                }
              end
            end
          end
        end
      end
    end
  end
end

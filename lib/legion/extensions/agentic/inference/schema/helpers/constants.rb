# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Schema
          module Helpers
            module Constants
              RELATION_TYPES = %i[
                causes
                prevents
                enables
                requires
                correlates
                contradicts
              ].freeze

              CONFIDENCE_LEVELS = {
                established: 0.9,
                strong:      0.7,
                moderate:    0.5,
                weak:        0.3,
                speculative: 0.1
              }.freeze

              SCHEMA_ALPHA = 0.12

              MAX_SCHEMAS = 500

              MAX_RELATIONS_PER_SCHEMA = 50

              REINFORCEMENT_BONUS = 0.05

              CONTRADICTION_PENALTY = 0.15

              DECAY_RATE = 0.005

              PRUNE_THRESHOLD = 0.1

              MAX_COUNTERFACTUAL_DEPTH = 5

              MAX_EXPLANATION_CHAIN = 10
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module PredictiveProcessing
          module Helpers
            module Constants
              MAX_MODELS                  = 20
              MAX_PREDICTIONS_PER_MODEL   = 50
              MAX_HISTORY                 = 200
              DEFAULT_PRECISION           = 0.5
              PRECISION_FLOOR             = 0.05
              PRECISION_DECAY             = 0.02
              MODEL_CONFIDENCE_FLOOR      = 0.1
              FREE_ENERGY_THRESHOLD       = 0.7
              ACTIVE_INFERENCE_THRESHOLD  = 0.5
              LEARNING_RATE               = 0.1
              INFERENCE_MODES             = %i[perceptual active hybrid].freeze
              MODEL_STATES                = %i[stable updating exploring surprised].freeze
              PRECISION_LABELS            = {
                (0.8..)     => :certain,
                (0.6...0.8) => :confident,
                (0.4...0.6) => :uncertain,
                (0.2...0.4) => :vague,
                (..0.2)     => :noise
              }.freeze
            end
          end
        end
      end
    end
  end
end

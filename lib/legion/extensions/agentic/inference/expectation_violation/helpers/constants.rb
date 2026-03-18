# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module ExpectationViolation
          module Helpers
            module Constants
              VIOLATION_TYPES = %i[positive negative neutral].freeze

              VIOLATION_LABELS = {
                (0.8..)       => :extreme_positive,
                (0.3...0.8)   => :positive,
                (-0.3...0.3)  => :neutral,
                (-0.8...-0.3) => :negative,
                (..-0.8)      => :extreme_negative
              }.freeze

              AROUSAL_LABELS = {
                (0.8..)     => :highly_aroused,
                (0.6...0.8) => :aroused,
                (0.4...0.6) => :moderate,
                (0.2...0.4) => :calm,
                (..0.2)     => :unaffected
              }.freeze

              MAX_EXPECTATIONS = 200
              MAX_VIOLATIONS   = 500
              MAX_HISTORY      = 500

              DEFAULT_EXPECTATION = 0.5
              EXPECTATION_FLOOR   = 0.0
              EXPECTATION_CEILING = 1.0

              AROUSAL_BASE = 0.3
              AROUSAL_MULTIPLIER = 0.7

              ADAPTATION_RATE = 0.1
              DECAY_RATE      = 0.02
            end
          end
        end
      end
    end
  end
end

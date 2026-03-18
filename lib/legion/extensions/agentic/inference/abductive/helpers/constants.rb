# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Abductive
          module Helpers
            module Constants
              MAX_OBSERVATIONS     = 200
              MAX_HYPOTHESES       = 100
              MAX_EXPLANATIONS     = 500
              MAX_HISTORY          = 300
              DEFAULT_PLAUSIBILITY = 0.5
              PLAUSIBILITY_FLOOR   = 0.0
              PLAUSIBILITY_CEILING = 1.0
              SIMPLICITY_WEIGHT    = 0.3
              EXPLANATORY_POWER_WEIGHT = 0.4
              PRIOR_WEIGHT         = 0.3
              EVIDENCE_BOOST       = 0.1
              CONTRADICTION_PENALTY = 0.2
              DECAY_RATE           = 0.02
              STALE_THRESHOLD      = 120
              SURPRISE_LEVELS      = %i[trivial expected notable surprising shocking].freeze
              HYPOTHESIS_STATES    = %i[candidate supported refuted].freeze
              QUALITY_LABELS       = {
                (0.8..)     => :compelling,
                (0.6...0.8) => :plausible,
                (0.4...0.6) => :possible,
                (0.2...0.4) => :weak,
                (..0.2)     => :implausible
              }.freeze
            end
          end
        end
      end
    end
  end
end

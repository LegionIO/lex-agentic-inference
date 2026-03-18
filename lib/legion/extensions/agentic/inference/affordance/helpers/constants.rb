# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Affordance
          module Helpers
            module Constants
              MAX_AFFORDANCES       = 200
              MAX_CAPABILITIES      = 50
              MAX_ENVIRONMENT_PROPS = 100
              MAX_HISTORY           = 200

              RELEVANCE_FLOOR       = 0.05
              RELEVANCE_DECAY       = 0.01
              DEFAULT_RELEVANCE     = 0.5
              URGENCY_BOOST         = 0.2

              CAPABILITY_MATCH_THRESHOLD = 0.3
              ACTIONABLE_THRESHOLD       = 0.5

              AFFORDANCE_TYPES = %i[
                action_possible action_blocked action_risky
                resource_available resource_depleted
                opportunity threat neutral
              ].freeze

              RELEVANCE_LABELS = {
                (0.8..)     => :critical,
                (0.6...0.8) => :important,
                (0.4...0.6) => :moderate,
                (0.2...0.4) => :minor,
                (..0.2)     => :negligible
              }.freeze
            end
          end
        end
      end
    end
  end
end

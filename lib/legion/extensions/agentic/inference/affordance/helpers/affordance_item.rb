# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Affordance
          module Helpers
            class AffordanceItem
              include Constants

              attr_reader :id, :action, :domain, :affordance_type, :requires, :detected_at
              attr_accessor :relevance

              def initialize(id:, action:, domain:, affordance_type:, requires: [], relevance: DEFAULT_RELEVANCE)
                @id              = id
                @action          = action
                @domain          = domain
                @affordance_type = affordance_type
                @requires        = Array(requires)
                @relevance       = relevance.to_f.clamp(0.0, 1.0)
                @detected_at     = Time.now.utc
              end

              def actionable?
                %i[action_possible resource_available opportunity].include?(@affordance_type) &&
                  @relevance >= ACTIONABLE_THRESHOLD
              end

              def blocked?
                @affordance_type == :action_blocked
              end

              def risky?
                @affordance_type == :action_risky
              end

              def threatening?
                @affordance_type == :threat
              end

              def decay
                @relevance = [@relevance - RELEVANCE_DECAY, 0.0].max
              end

              def faded?
                @relevance <= RELEVANCE_FLOOR
              end

              def relevance_label
                RELEVANCE_LABELS.each { |range, lbl| return lbl if range.cover?(@relevance) }
                :negligible
              end

              def to_h
                {
                  id:              @id,
                  action:          @action,
                  domain:          @domain,
                  affordance_type: @affordance_type,
                  requires:        @requires,
                  relevance:       @relevance.round(4),
                  relevance_label: relevance_label,
                  actionable:      actionable?,
                  blocked:         blocked?,
                  risky:           risky?
                }
              end
            end
          end
        end
      end
    end
  end
end

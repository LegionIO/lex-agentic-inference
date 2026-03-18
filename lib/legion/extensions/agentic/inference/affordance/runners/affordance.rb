# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Affordance
          module Runners
            module Affordance
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex)

              def register_capability(name:, domain: :general, level: 1.0, **)
                Legion::Logging.debug "[affordance] capability: #{name} domain=#{domain}"
                cap = field.register_capability(name: name, domain: domain, level: level)
                if cap
                  { success: true, capability: name, capabilities: field.capabilities.size }
                else
                  { success: false, reason: :limit_reached }
                end
              end

              def set_environment(property:, value:, domain: :general, **)
                Legion::Logging.debug "[affordance] env: #{property}=#{value}"
                result = field.set_environment(property: property, value: value, domain: domain)
                if result
                  { success: true, property: property }
                else
                  { success: false, reason: :limit_reached }
                end
              end

              def detect_affordance(action:, domain:, affordance_type:, requires: [], relevance: nil, **)
                rel = relevance || Helpers::Constants::DEFAULT_RELEVANCE
                Legion::Logging.debug "[affordance] detect: #{action} type=#{affordance_type}"
                aff = field.detect_affordance(
                  action: action, domain: domain, affordance_type: affordance_type.to_sym,
                  requires: requires, relevance: rel
                )
                if aff
                  { success: true, affordance: aff.to_h }
                else
                  { success: false, reason: :invalid_or_full }
                end
              end

              def evaluate_action(action:, domain:, **)
                result = field.evaluate_action(action: action, domain: domain)
                Legion::Logging.debug "[affordance] evaluate: #{action} feasible=#{result[:feasible]}"
                { success: true, **result }
              end

              def actionable_affordances(**)
                items = field.actionable_affordances
                { success: true, affordances: items, count: items.size }
              end

              def current_threats(**)
                items = field.threats
                { success: true, threats: items, count: items.size }
              end

              def affordances_in_domain(domain:, **)
                items = field.affordances_in(domain: domain)
                { success: true, affordances: items, count: items.size }
              end

              def update_affordances(**)
                Legion::Logging.debug '[affordance] tick'
                field.decay_all
                { success: true, remaining: field.affordances.size }
              end

              def affordance_stats(**)
                Legion::Logging.debug '[affordance] stats'
                { success: true, stats: field.to_h }
              end

              private

              def field
                @field ||= Helpers::AffordanceField.new
              end
            end
          end
        end
      end
    end
  end
end

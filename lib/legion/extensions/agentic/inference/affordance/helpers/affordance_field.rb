# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Affordance
          module Helpers
            class AffordanceField
              include Constants

              attr_reader :affordances, :capabilities, :environment

              def initialize
                @affordances   = {}
                @capabilities  = {}
                @environment   = {}
                @counter       = 0
                @history       = []
              end

              def register_capability(name:, domain: :general, level: 1.0)
                return nil if @capabilities.size >= MAX_CAPABILITIES

                @capabilities[name] = { domain: domain, level: level.to_f.clamp(0.0, 1.0) }
              end

              def set_environment(property:, value:, domain: :general)
                return nil if @environment.size >= MAX_ENVIRONMENT_PROPS && !@environment.key?(property)

                @environment[property] = { value: value, domain: domain, updated_at: Time.now.utc }
              end

              def detect_affordance(action:, domain:, affordance_type:, requires: [], relevance: DEFAULT_RELEVANCE)
                return nil unless AFFORDANCE_TYPES.include?(affordance_type)
                return nil if @affordances.size >= MAX_AFFORDANCES

                @counter += 1
                aff_id = :"aff_#{@counter}"
                aff = AffordanceItem.new(
                  id: aff_id, action: action, domain: domain,
                  affordance_type: affordance_type, requires: requires, relevance: relevance
                )
                @affordances[aff_id] = aff
                record_detection(aff)
                aff
              end

              def evaluate_action(action:, domain:)
                matching = @affordances.values.select { |a| a.action == action && a.domain == domain }
                return { feasible: false, reason: :no_affordance } if matching.empty?

                check_blockers(matching) || build_evaluation(matching)
              end

              def actionable_affordances
                @affordances.values.select(&:actionable?).sort_by { |a| -a.relevance }.map(&:to_h)
              end

              def threats
                @affordances.values.select(&:threatening?).map(&:to_h)
              end

              def affordances_in(domain:)
                @affordances.values.select { |a| a.domain == domain }.map(&:to_h)
              end

              def decay_all
                @affordances.each_value(&:decay)
                @affordances.reject! { |_, a| a.faded? }
              end

              def to_h
                {
                  affordance_count:  @affordances.size,
                  capability_count:  @capabilities.size,
                  environment_props: @environment.size,
                  actionable_count:  @affordances.values.count(&:actionable?),
                  blocked_count:     @affordances.values.count(&:blocked?),
                  threat_count:      @affordances.values.count(&:threatening?),
                  history_size:      @history.size
                }
              end

              private

              def check_blockers(matching)
                blockers = matching.select(&:blocked?)
                return nil if blockers.empty?

                { feasible: false, reason: :blocked, blockers: blockers.map(&:to_h) }
              end

              def build_evaluation(matching)
                capabilities_met = check_requirements(matching)
                {
                  feasible:         capabilities_met,
                  reason:           capabilities_met ? :capable : :missing_capabilities,
                  risks:            matching.select(&:risky?).map(&:to_h),
                  relevance:        matching.map(&:relevance).max,
                  affordance_count: matching.size
                }
              end

              def check_requirements(affordances)
                required = affordances.flat_map(&:requires).uniq
                return true if required.empty?

                required.all? { |r| @capabilities.key?(r) }
              end

              def record_detection(affordance)
                @history << { id: affordance.id, action: affordance.action, type: affordance.affordance_type,
                              at: Time.now.utc }
                @history.shift while @history.size > MAX_HISTORY
              end
            end
          end
        end
      end
    end
  end
end

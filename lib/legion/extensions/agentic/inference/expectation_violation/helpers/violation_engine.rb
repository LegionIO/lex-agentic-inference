# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module ExpectationViolation
          module Helpers
            class ViolationEngine
              include Constants

              attr_reader :history

              def initialize
                @expectations = {}
                @violations   = []
                @history      = []
              end

              def create_expectation(context:, domain:, expected_value: DEFAULT_EXPECTATION, tolerance: 0.2)
                evict_oldest if @expectations.size >= MAX_EXPECTATIONS

                expectation = Expectation.new(
                  context:        context,
                  domain:         domain,
                  expected_value: expected_value,
                  tolerance:      tolerance
                )
                @expectations[expectation.id] = expectation
                record_history(:created, expectation.id)
                expectation
              end

              def evaluate_against(expectation_id:, actual_value:)
                expectation = @expectations[expectation_id]
                return { success: false, reason: :not_found } unless expectation

                result = expectation.evaluate(actual_value: actual_value)

                if result[:violated]
                  @violations << {
                    expectation_id: expectation_id,
                    type:           result[:type],
                    deviation:      result[:deviation],
                    arousal:        result[:arousal],
                    at:             Time.now.utc
                  }
                  trim_violations
                end

                record_history(:evaluated, expectation_id)
                { success: true }.merge(result)
              end

              def adapt_expectation(expectation_id:, actual_value:)
                expectation = @expectations[expectation_id]
                return { success: false, reason: :not_found } unless expectation

                expectation.adapt!(actual_value: actual_value)
                record_history(:adapted, expectation_id)
                { success: true, new_expected: expectation.expected_value.round(3) }
              end

              def recent_violations(limit: 10)
                @violations.last(limit)
              end

              def violations_by_type(type:)
                @violations.select { |vio| vio[:type] == type }
              end

              def expectations_by_domain(domain:)
                @expectations.values.select { |exp| exp.domain == domain }
              end

              def most_violated(limit: 5)
                @expectations.values.sort_by { |exp| -exp.violation_count }.first(limit)
              end

              def prune_stale_violations(cutoff:)
                before = @violations.size
                @violations.reject! { |vio| vio[:at] < cutoff }
                before - @violations.size
              end

              def violation_rate
                total = @expectations.values.sum(&:violation_count)
                evals = @history.count { |entry| entry[:event] == :evaluated }
                return 0.0 if evals.zero?

                (total.to_f / evals).round(3)
              end

              def positive_violation_ratio
                return 0.0 if @violations.empty?

                positive = @violations.count { |vio| vio[:type] == :positive }
                (positive.to_f / @violations.size).round(3)
              end

              def to_h
                {
                  total_expectations: @expectations.size,
                  total_violations:   @violations.size,
                  violation_rate:     violation_rate,
                  positive_ratio:     positive_violation_ratio,
                  history_count:      @history.size
                }
              end

              private

              def evict_oldest
                oldest_id = @expectations.min_by { |_id, exp| exp.created_at }&.first
                @expectations.delete(oldest_id) if oldest_id
              end

              def trim_violations
                @violations.shift while @violations.size > MAX_VIOLATIONS
              end

              def record_history(event, expectation_id)
                @history << { event: event, expectation_id: expectation_id, at: Time.now.utc }
                @history.shift while @history.size > MAX_HISTORY
              end
            end
          end
        end
      end
    end
  end
end

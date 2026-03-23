# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module ExpectationViolation
          module Runners
            module ExpectationViolation
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex)

              def create_expectation(context:, domain:, expected_value: nil, tolerance: 0.2, **)
                exp = engine.create_expectation(
                  context:        context,
                  domain:         domain.to_sym,
                  expected_value: expected_value || Helpers::Constants::DEFAULT_EXPECTATION,
                  tolerance:      tolerance
                )
                log.debug "[expectation_violation] create id=#{exp.id[0..7]} " \
                          "ctx=#{context} expected=#{exp.expected_value}"
                { success: true, expectation: exp.to_h }
              end

              def evaluate_expectation(expectation_id:, actual_value:, **)
                result = engine.evaluate_against(expectation_id: expectation_id, actual_value: actual_value)
                log.debug "[expectation_violation] evaluate id=#{expectation_id[0..7]} " \
                          "violated=#{result[:violated]} type=#{result[:type]}"
                result
              end

              def adapt_expectation_value(expectation_id:, actual_value:, **)
                result = engine.adapt_expectation(expectation_id: expectation_id, actual_value: actual_value)
                log.debug "[expectation_violation] adapt id=#{expectation_id[0..7]} " \
                          "new=#{result[:new_expected]}"
                result
              end

              def recent_violations_report(limit: 10, **)
                violations = engine.recent_violations(limit: limit)
                log.debug "[expectation_violation] recent count=#{violations.size}"
                { success: true, violations: violations, count: violations.size }
              end

              def violations_by_type_report(type:, **)
                violations = engine.violations_by_type(type: type.to_sym)
                log.debug '[expectation_violation] by_type ' \
                          "type=#{type} count=#{violations.size}"
                { success: true, violations: violations, count: violations.size }
              end

              def most_violated_expectations(limit: 5, **)
                exps = engine.most_violated(limit: limit)
                log.debug "[expectation_violation] most_violated count=#{exps.size}"
                { success: true, expectations: exps.map(&:to_h), count: exps.size }
              end

              def expectation_violation_stats(**)
                stats = engine.to_h
                log.debug '[expectation_violation] stats ' \
                          "total=#{stats[:total_expectations]}"
                { success: true }.merge(stats)
              end

              private

              def engine
                @engine ||= Helpers::ViolationEngine.new
              end
            end
          end
        end
      end
    end
  end
end

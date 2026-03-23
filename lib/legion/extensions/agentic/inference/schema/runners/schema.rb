# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Schema
          module Runners
            module Schema
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex)

              def update_schema(tick_results: {}, **)
                extract_prediction_outcomes(tick_results)
                world_model.decay_all

                log.debug "[schema] relations=#{world_model.relation_count} " \
                          "domains=#{world_model.domain_count} established=#{world_model.established_relations.size}"

                world_model.to_h
              end

              def learn_relation(cause:, effect:, relation_type:, confidence: 0.5, **)
                relation_sym = relation_type.to_sym
                result = world_model.add_relation(cause: cause, effect: effect, relation_type: relation_sym, confidence: confidence)
                return { success: false, error: 'invalid relation type' } unless result

                log.info "[schema] learned: #{cause} #{relation_sym} #{effect} (#{result.confidence.round(2)})"
                { success: true, relation: result.to_h }
              end

              def weaken_relation(cause:, effect:, relation_type:, **)
                result = world_model.weaken_relation(cause: cause, effect: effect, relation_type: relation_type.to_sym)
                return { success: false, error: 'relation not found' } unless result

                log.debug "[schema] weakened: #{cause} #{relation_type} #{effect}"
                { success: true, relation: result.to_h }
              end

              def explain(outcome:, **)
                chain = world_model.explain(outcome)
                log.debug "[schema] explanation for #{outcome}: #{chain.size} links"
                { outcome: outcome, chain: chain, depth: chain.size }
              end

              def counterfactual(cause:, **)
                affected = world_model.counterfactual(cause)
                log.debug "[schema] counterfactual for #{cause}: #{affected.size} effects"
                { cause: cause, affected: affected, impact: affected.size }
              end

              def find_effects(cause:, **)
                effects = world_model.find_effects(cause).map(&:to_h)
                { cause: cause, effects: effects, count: effects.size }
              end

              def find_causes(effect:, **)
                causes = world_model.find_causes(effect).map(&:to_h)
                { effect: effect, causes: causes, count: causes.size }
              end

              def contradictions(**)
                result = world_model.contradictions
                log.debug "[schema] contradictions: #{result.size}"
                { contradictions: result, count: result.size }
              end

              def schema_stats(**)
                log.debug '[schema] stats'
                world_model.to_h.merge(
                  top_relations: world_model.established_relations.first(10).map(&:to_h)
                )
              end

              private

              def world_model
                @world_model ||= Helpers::WorldModel.new
              end

              def extract_prediction_outcomes(tick_results)
                predictions = tick_results.dig(:prediction_engine, :resolved)
                return unless predictions.is_a?(Array)

                predictions.each do |pred|
                  next unless pred[:domain] && pred[:outcome_domain]

                  if pred[:accurate]
                    world_model.add_relation(cause: pred[:domain], effect: pred[:outcome_domain], relation_type: :causes, confidence: 0.6)
                  else
                    world_model.weaken_relation(cause: pred[:domain], effect: pred[:outcome_domain], relation_type: :causes)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

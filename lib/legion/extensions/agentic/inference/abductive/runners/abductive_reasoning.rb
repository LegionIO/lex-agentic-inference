# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Abductive
          module Runners
            module AbductiveReasoning
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex)

              def record_observation(content:, domain:, surprise_level: :notable, context: {}, **)
                unless Helpers::Constants::SURPRISE_LEVELS.include?(surprise_level)
                  return { success: false, error: :invalid_surprise_level,
                           valid_levels: Helpers::Constants::SURPRISE_LEVELS }
                end

                obs = engine.record_observation(
                  content:        content,
                  domain:         domain,
                  surprise_level: surprise_level,
                  context:        context
                )
                Legion::Logging.debug "[abductive_reasoning] observation recorded: id=#{obs.id[0..7]} " \
                                      "domain=#{domain} surprise=#{surprise_level}"
                { success: true, observation: obs.to_h }
              end

              def generate_hypothesis(content:, observation_ids:, domain:, simplicity:,
                                      explanatory_power:, prior_probability: nil, **)
                prior = prior_probability || Helpers::Constants::DEFAULT_PLAUSIBILITY
                hyp = engine.generate_hypothesis(
                  content:           content,
                  observation_ids:   observation_ids,
                  domain:            domain,
                  simplicity:        simplicity,
                  explanatory_power: explanatory_power,
                  prior_probability: prior
                )
                Legion::Logging.debug "[abductive_reasoning] hypothesis generated: id=#{hyp.id[0..7]} " \
                                      "domain=#{domain} score=#{hyp.overall_score.round(3)}"
                { success: true, hypothesis: hyp.to_h }
              end

              def evaluate_hypothesis(hypothesis_id:, **)
                result = engine.evaluate_hypothesis(hypothesis_id: hypothesis_id)
                if result[:found] == false
                  Legion::Logging.debug "[abductive_reasoning] evaluate: not found id=#{hypothesis_id[0..7]}"
                  return { success: false, error: :not_found }
                end

                Legion::Logging.debug "[abductive_reasoning] evaluate: id=#{hypothesis_id[0..7]} " \
                                      "score=#{result[:score].round(3)} rank=#{result[:rank]} label=#{result[:quality_label]}"
                { success: true }.merge(result)
              end

              def add_hypothesis_evidence(hypothesis_id:, supporting:, **)
                result = engine.add_evidence(hypothesis_id: hypothesis_id, supporting: supporting)
                if result[:found] == false
                  Legion::Logging.debug "[abductive_reasoning] add_evidence: not found id=#{hypothesis_id[0..7]}"
                  return { success: false, error: :not_found }
                end

                Legion::Logging.debug "[abductive_reasoning] evidence added: id=#{hypothesis_id[0..7]} " \
                                      "supporting=#{supporting} state=#{result[:state]}"
                { success: true }.merge(result)
              end

              def best_explanation(observation_id:, **)
                hyp = engine.best_explanation(observation_id: observation_id)
                if hyp
                  Legion::Logging.debug "[abductive_reasoning] best_explanation: obs=#{observation_id[0..7]} " \
                                        "hyp=#{hyp.id[0..7]} score=#{hyp.overall_score.round(3)}"
                  { success: true, found: true, hypothesis: hyp.to_h }
                else
                  Legion::Logging.debug "[abductive_reasoning] best_explanation: obs=#{observation_id[0..7]} none found"
                  { success: true, found: false }
                end
              end

              def competing_hypotheses(observation_id:, **)
                ranked = engine.competing_hypotheses(observation_id: observation_id)
                Legion::Logging.debug "[abductive_reasoning] competing_hypotheses: obs=#{observation_id[0..7]} count=#{ranked.size}"
                { success: true, hypotheses: ranked.map(&:to_h), count: ranked.size }
              end

              def refute_hypothesis(hypothesis_id:, **)
                result = engine.refute_hypothesis(hypothesis_id: hypothesis_id)
                if result[:found] == false
                  Legion::Logging.debug "[abductive_reasoning] refute: not found id=#{hypothesis_id[0..7]}"
                  return { success: false, error: :not_found }
                end

                Legion::Logging.debug "[abductive_reasoning] hypothesis refuted: id=#{hypothesis_id[0..7]}"
                { success: true }.merge(result)
              end

              def unexplained_observations(**)
                observations = engine.unexplained_observations
                Legion::Logging.debug "[abductive_reasoning] unexplained_observations: count=#{observations.size}"
                { success: true, observations: observations.map(&:to_h), count: observations.size }
              end

              def update_abductive_reasoning(**)
                decayed = engine.decay_stale
                pruned  = engine.prune_refuted
                Legion::Logging.debug "[abductive_reasoning] update cycle: decayed=#{decayed} pruned=#{pruned}"
                { success: true, decayed: decayed, pruned: pruned }
              end

              def abductive_reasoning_stats(**)
                stats = engine.to_h
                Legion::Logging.debug "[abductive_reasoning] stats: #{stats.inspect}"
                { success: true }.merge(stats)
              end

              private

              def engine
                @engine ||= Helpers::AbductionEngine.new
              end
            end
          end
        end
      end
    end
  end
end

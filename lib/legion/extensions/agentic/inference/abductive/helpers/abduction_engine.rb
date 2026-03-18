# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Abductive
          module Helpers
            class AbductionEngine
              include Constants

              def initialize
                @observations = {}
                @hypotheses   = {}
              end

              def record_observation(content:, domain:, surprise_level: :notable, context: {})
                obs = Observation.new(
                  content:        content,
                  domain:         domain,
                  surprise_level: surprise_level,
                  context:        context
                )
                prune_observations if @observations.size >= Constants::MAX_OBSERVATIONS
                @observations[obs.id] = obs
                obs
              end

              def generate_hypothesis(content:, observation_ids:, domain:, simplicity:,
                                      explanatory_power:, prior_probability: Constants::DEFAULT_PLAUSIBILITY)
                hyp = Hypothesis.new(
                  content:           content,
                  observation_ids:   observation_ids,
                  domain:            domain,
                  simplicity:        simplicity,
                  explanatory_power: explanatory_power,
                  prior_probability: prior_probability
                )
                prune_hypotheses if @hypotheses.size >= Constants::MAX_HYPOTHESES
                @hypotheses[hyp.id] = hyp
                hyp
              end

              def evaluate_hypothesis(hypothesis_id:)
                hyp = @hypotheses[hypothesis_id]
                return { found: false } unless hyp

                hyp.instance_variable_set(:@last_evaluated_at, Time.now.utc)
                ranked = ranked_hypotheses_for_observations(hyp.observation_ids)
                rank = ranked.index { |h| h.id == hypothesis_id }.to_i + 1

                {
                  score:         hyp.overall_score,
                  rank:          rank,
                  quality_label: hyp.quality_label
                }
              end

              def add_evidence(hypothesis_id:, supporting:)
                hyp = @hypotheses[hypothesis_id]
                return { found: false } unless hyp

                hyp.add_evidence(supporting: supporting)
                { found: true, hypothesis_id: hypothesis_id, state: hyp.state, plausibility: hyp.plausibility }
              end

              def best_explanation(observation_id:)
                candidates = active_hypotheses_for(observation_id)
                return nil if candidates.empty?

                candidates.max_by(&:overall_score)
              end

              def competing_hypotheses(observation_id:)
                active_hypotheses_for(observation_id).sort_by { |h| -h.overall_score }
              end

              def refute_hypothesis(hypothesis_id:)
                hyp = @hypotheses[hypothesis_id]
                return { found: false } unless hyp

                hyp.refute!
                { found: true, hypothesis_id: hypothesis_id, state: hyp.state }
              end

              def find_by_domain(domain:)
                @hypotheses.values.select { |h| h.domain == domain && h.state != :refuted }
              end

              def unexplained_observations
                @observations.values.reject do |obs|
                  @hypotheses.values.any? do |h|
                    h.state == :supported && h.observation_ids.include?(obs.id)
                  end
                end
              end

              def decay_stale
                cutoff = Time.now.utc - Constants::STALE_THRESHOLD
                decayed = 0
                @hypotheses.each_value do |hyp|
                  next if hyp.state == :refuted
                  next if hyp.last_evaluated_at >= cutoff

                  hyp.plausibility = (hyp.plausibility - Constants::DECAY_RATE).clamp(
                    Constants::PLAUSIBILITY_FLOOR,
                    Constants::PLAUSIBILITY_CEILING
                  )
                  decayed += 1
                end
                decayed
              end

              def prune_refuted
                before = @hypotheses.size
                @hypotheses.delete_if { |_, h| h.state == :refuted }
                before - @hypotheses.size
              end

              def to_h
                {
                  observation_count: @observations.size,
                  hypothesis_count:  @hypotheses.size,
                  supported_count:   @hypotheses.values.count { |h| h.state == :supported },
                  refuted_count:     @hypotheses.values.count { |h| h.state == :refuted },
                  candidate_count:   @hypotheses.values.count { |h| h.state == :candidate },
                  unexplained_count: unexplained_observations.size
                }
              end

              private

              def active_hypotheses_for(observation_id)
                @hypotheses.values.select do |h|
                  h.state != :refuted && h.observation_ids.include?(observation_id)
                end
              end

              def ranked_hypotheses_for_observations(observation_ids)
                obs_set = Array(observation_ids)
                @hypotheses.values
                           .select { |h| h.state != :refuted && h.observation_ids.intersect?(obs_set) }
                           .sort_by { |h| -h.overall_score }
              end

              def prune_observations
                sorted = @observations.values.sort_by(&:created_at)
                excess = @observations.size - Constants::MAX_OBSERVATIONS + 1
                sorted.first(excess).each { |obs| @observations.delete(obs.id) }
              end

              def prune_hypotheses
                candidates = @hypotheses.values.select { |h| h.state == :candidate }
                sorted = candidates.sort_by(&:created_at)
                excess = @hypotheses.size - Constants::MAX_HYPOTHESES + 1
                sorted.first(excess).each { |h| @hypotheses.delete(h.id) }
              end
            end
          end
        end
      end
    end
  end
end

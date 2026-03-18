# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Schema
          module Helpers
            class WorldModel
              attr_reader :relations, :domains

              def initialize
                @relations = {}
                @domains   = Hash.new { |h, k| h[k] = [] }
              end

              def add_relation(cause:, effect:, relation_type:, confidence: 0.5)
                return nil unless Constants::RELATION_TYPES.include?(relation_type)

                key = relation_key(cause, effect, relation_type)
                if @relations.key?(key)
                  @relations[key].reinforce
                else
                  @relations[key] = CausalRelation.new(cause: cause, effect: effect, relation_type: relation_type, confidence: confidence)
                  index_domains(cause, effect, key)
                  trim_relations
                end
                @relations[key]
              end

              def weaken_relation(cause:, effect:, relation_type:)
                key = relation_key(cause, effect, relation_type)
                relation = @relations[key]
                return nil unless relation

                relation.weaken
                prune_if_needed(key)
                relation
              end

              def find_effects(cause)
                keys = @domains[cause] || []
                keys.filter_map { |k| @relations[k] }.select { |r| r.cause == cause }
              end

              def find_causes(effect)
                keys = @domains[effect] || []
                keys.filter_map { |k| @relations[k] }.select { |r| r.effect == effect }
              end

              def explain(outcome, max_depth: Constants::MAX_EXPLANATION_CHAIN)
                chain = []
                visited = Set.new
                build_explanation_chain(outcome, chain, visited, max_depth)
                chain
              end

              def counterfactual(cause, max_depth: Constants::MAX_COUNTERFACTUAL_DEPTH)
                affected = []
                visited  = Set.new
                propagate_counterfactual(cause, affected, visited, max_depth)
                affected
              end

              def contradictions
                @relations.values.each_with_object([]) do |rel, result|
                  next unless rel.relation_type == :causes

                  opposite = @relations[relation_key(rel.cause, rel.effect, :prevents)]
                  next unless opposite

                  result << {
                    cause:               rel.cause,
                    effect:              rel.effect,
                    causes_confidence:   rel.confidence.round(4),
                    prevents_confidence: opposite.confidence.round(4)
                  }
                end
              end

              def decay_all
                @relations.each_value(&:decay)
                prune_weak
              end

              def relation_count
                @relations.size
              end

              def domain_count
                all_entities = @relations.values.flat_map { |r| [r.cause, r.effect] }
                all_entities.uniq.size
              end

              def established_relations
                @relations.values.select(&:established?)
              end

              def to_h
                {
                  relation_count:      relation_count,
                  domain_count:        domain_count,
                  established_count:   established_relations.size,
                  contradiction_count: contradictions.size
                }
              end

              private

              def relation_key(cause, effect, relation_type)
                "#{cause}->#{relation_type}->#{effect}"
              end

              def index_domains(cause, effect, key)
                @domains[cause] << key
                @domains[effect] << key
              end

              def build_explanation_chain(outcome, chain, visited, depth)
                return if depth <= 0 || visited.include?(outcome)

                visited.add(outcome)
                causes = find_causes(outcome).sort_by { |r| -r.confidence }
                causes.first(3).each do |rel|
                  chain << rel.to_h
                  build_explanation_chain(rel.cause, chain, visited, depth - 1)
                end
              end

              def propagate_counterfactual(cause, affected, visited, depth)
                return if depth <= 0 || visited.include?(cause)

                visited.add(cause)
                effects = find_effects(cause).sort_by { |r| -r.confidence }
                effects.each do |rel|
                  affected << { effect: rel.effect, relation: rel.relation_type, confidence: rel.confidence.round(4) }
                  propagate_counterfactual(rel.effect, affected, visited, depth - 1)
                end
              end

              def prune_if_needed(key)
                relation = @relations[key]
                return unless relation&.prunable?

                remove_relation(key)
              end

              def prune_weak
                prunable = @relations.select { |_, r| r.prunable? }.keys
                prunable.each { |key| remove_relation(key) }
              end

              def remove_relation(key)
                rel = @relations.delete(key)
                return unless rel

                @domains[rel.cause]&.delete(key)
                @domains[rel.effect]&.delete(key)
              end

              def trim_relations
                return if @relations.size <= Constants::MAX_SCHEMAS

                weakest = @relations.sort_by { |_, r| r.confidence }
                weakest.first(@relations.size - Constants::MAX_SCHEMAS).each { |k, _| remove_relation(k) } # rubocop:disable Style/HashEachMethods
              end
            end
          end
        end
      end
    end
  end
end

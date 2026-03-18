# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Momentum
          module Helpers
            class MomentumEngine
              include Constants

              attr_reader :history

              def initialize
                @ideas   = {}
                @history = []
              end

              def create_idea(content:, idea_type:, domain:, mass: DEFAULT_MASS)
                evict_oldest if @ideas.size >= MAX_IDEAS

                idea = Idea.new(content: content, idea_type: idea_type, domain: domain, mass: mass)
                @ideas[idea.id] = idea
                record_history(:created, idea.id)
                idea
              end

              def reinforce_idea(idea_id:)
                idea = @ideas[idea_id]
                return { success: false, reason: :not_found } unless idea

                idea.reinforce!
                record_history(:reinforced, idea_id)
                { success: true, momentum: idea.momentum, mass: idea.mass, velocity: idea.velocity }
              end

              def challenge_idea(idea_id:)
                idea = @ideas[idea_id]
                return { success: false, reason: :not_found } unless idea

                idea.challenge!
                record_history(:challenged, idea_id)
                { success: true, momentum: idea.momentum, mass: idea.mass, velocity: idea.velocity }
              end

              def apply_force(idea_id:, force:)
                idea = @ideas[idea_id]
                return { success: false, reason: :not_found } unless idea

                idea.apply_force(force: force)
                record_history(:force_applied, idea_id)
                { success: true, momentum: idea.momentum, velocity: idea.velocity }
              end

              def surging_ideas
                @ideas.values.select(&:surging?)
              end

              def reversing_ideas
                @ideas.values.select(&:reversing?)
              end

              def entrenched_ideas
                @ideas.values.select(&:entrenched?)
              end

              def ideas_by_type(idea_type:)
                @ideas.values.select { |idea| idea.idea_type == idea_type }
              end

              def ideas_by_domain(domain:)
                @ideas.values.select { |idea| idea.domain == domain }
              end

              def highest_momentum(limit: 5)
                @ideas.values.sort_by { |idea| -idea.momentum }.first(limit)
              end

              def most_entrenched(limit: 5)
                @ideas.values.sort_by { |idea| -idea.mass }.first(limit)
              end

              def apply_friction_all
                @ideas.each_value(&:apply_friction!)
              end

              def prune_at_rest
                ids = @ideas.select { |_id, idea| idea.at_rest? && idea.mass <= MASS_FLOOR + 0.01 }.keys
                ids.each { |idea_id| @ideas.delete(idea_id) }
                ids.size
              end

              def to_h
                {
                  total_ideas:      @ideas.size,
                  surging_count:    surging_ideas.size,
                  reversing_count:  reversing_ideas.size,
                  entrenched_count: entrenched_ideas.size,
                  avg_momentum:     avg_momentum,
                  history_count:    @history.size
                }
              end

              private

              def avg_momentum
                return 0.0 if @ideas.empty?

                @ideas.values.sum(&:momentum) / @ideas.size
              end

              def evict_oldest
                oldest_id = @ideas.min_by { |_id, idea| idea.last_updated_at }&.first
                @ideas.delete(oldest_id) if oldest_id
              end

              def record_history(event, idea_id)
                @history << { event: event, idea_id: idea_id, at: Time.now.utc }
                @history.shift while @history.size > MAX_HISTORY
              end
            end
          end
        end
      end
    end
  end
end

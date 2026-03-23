# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Momentum
          module Runners
            module CognitiveMomentum
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex)

              def create_cognitive_idea(content:, idea_type:, domain:, mass: nil, **)
                idea = engine.create_idea(
                  content:   content,
                  idea_type: idea_type.to_sym,
                  domain:    domain.to_sym,
                  mass:      mass || Helpers::Constants::DEFAULT_MASS
                )
                log.debug "[cognitive_momentum] create id=#{idea.id[0..7]} " \
                          "type=#{idea_type} domain=#{domain}"
                { success: true, idea: idea.to_h }
              end

              def reinforce_cognitive_idea(idea_id:, **)
                result = engine.reinforce_idea(idea_id: idea_id)
                log.debug "[cognitive_momentum] reinforce id=#{idea_id[0..7]} " \
                          "momentum=#{result[:momentum]&.round(3)}"
                result
              end

              def challenge_cognitive_idea(idea_id:, **)
                result = engine.challenge_idea(idea_id: idea_id)
                log.debug "[cognitive_momentum] challenge id=#{idea_id[0..7]} " \
                          "momentum=#{result[:momentum]&.round(3)}"
                result
              end

              def apply_cognitive_force(idea_id:, force:, **)
                result = engine.apply_force(idea_id: idea_id, force: force)
                log.debug "[cognitive_momentum] force id=#{idea_id[0..7]} " \
                          "f=#{force} momentum=#{result[:momentum]&.round(3)}"
                result
              end

              def surging_ideas_report(**)
                ideas = engine.surging_ideas
                log.debug "[cognitive_momentum] surging count=#{ideas.size}"
                { success: true, ideas: ideas.map(&:to_h), count: ideas.size }
              end

              def reversing_ideas_report(**)
                ideas = engine.reversing_ideas
                log.debug "[cognitive_momentum] reversing count=#{ideas.size}"
                { success: true, ideas: ideas.map(&:to_h), count: ideas.size }
              end

              def entrenched_ideas_report(**)
                ideas = engine.entrenched_ideas
                log.debug "[cognitive_momentum] entrenched count=#{ideas.size}"
                { success: true, ideas: ideas.map(&:to_h), count: ideas.size }
              end

              def highest_momentum_ideas(limit: 5, **)
                ideas = engine.highest_momentum(limit: limit)
                log.debug "[cognitive_momentum] highest_momentum count=#{ideas.size}"
                { success: true, ideas: ideas.map(&:to_h), count: ideas.size }
              end

              def ideas_by_domain(domain:, **)
                ideas = engine.ideas_by_domain(domain: domain.to_sym)
                log.debug '[cognitive_momentum] by_domain ' \
                          "domain=#{domain} count=#{ideas.size}"
                { success: true, ideas: ideas.map(&:to_h), count: ideas.size }
              end

              def update_cognitive_momentum(**)
                engine.apply_friction_all
                pruned = engine.prune_at_rest
                log.debug "[cognitive_momentum] friction+prune pruned=#{pruned}"
                { success: true, pruned: pruned }
              end

              def cognitive_momentum_stats(**)
                stats = engine.to_h
                log.debug "[cognitive_momentum] stats total=#{stats[:total_ideas]}"
                { success: true }.merge(stats)
              end

              private

              def engine
                @engine ||= Helpers::MomentumEngine.new
              end
            end
          end
        end
      end
    end
  end
end

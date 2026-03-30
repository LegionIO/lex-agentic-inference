# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Gravity
          module Runners
            module Gravity
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def create_attractor(content:, domain: :unknown, mass: Helpers::Constants::DEFAULT_MASS,
                                   pull_radius: 1.0, decay_rate: 0.01, engine: nil, **)
                eng = engine || gravity_engine
                unless Helpers::Constants.valid_domain?(domain)
                  return { success: false, error: :invalid_domain,
                           valid_domains: Helpers::Constants::ATTRACTOR_DOMAINS }
                end

                result = eng.add_attractor(
                  content:     content,
                  domain:      domain,
                  mass:        mass,
                  pull_radius: pull_radius,
                  decay_rate:  decay_rate
                )

                if result.is_a?(Hash) && result[:error]
                  log.warn "[cognitive_gravity] create_attractor failed: #{result[:error]}"
                  return { success: false, **result }
                end

                log.debug "[cognitive_gravity] attractor created id=#{result.id[0..7]} " \
                          "domain=#{domain} mass=#{mass}"
                { success: true, attractor: result.to_h }
              end

              def add_thought(content:, attractor_id:, orbital_distance: 1.0, velocity: 0.0,
                              engine: nil, **)
                eng = engine || gravity_engine
                result = eng.add_orbiting_thought(
                  content:          content,
                  attractor_id:     attractor_id,
                  orbital_distance: orbital_distance,
                  velocity:         velocity
                )

                if result.is_a?(Hash) && result[:error]
                  log.warn "[cognitive_gravity] add_thought failed: #{result[:error]}"
                  return { success: false, **result }
                end

                log.debug "[cognitive_gravity] thought added id=#{result.id[0..7]} " \
                          "attractor=#{attractor_id[0..7]} distance=#{orbital_distance}"
                { success: true, thought: result.to_h }
              end

              def tick_gravity(engine: nil, **)
                eng = engine || gravity_engine
                result = eng.simulate_tick
                log.debug "[cognitive_gravity] tick: captures=#{result[:captures].size} " \
                          "escapes=#{result[:escapes].size}"
                { success: true, **result }
              end

              def accrete(attractor_id:, amount: Helpers::Constants::MASS_ACCRETION, engine: nil, **)
                eng = engine || gravity_engine
                result = eng.accrete_attractor(attractor_id, amount: amount)

                if result[:error]
                  log.warn "[cognitive_gravity] accrete failed: #{result[:error]}"
                  return { success: false, **result }
                end

                log.debug "[cognitive_gravity] accreted id=#{attractor_id[0..7]} mass=#{result[:mass]}"
                { success: true, **result }
              end

              def erode(attractor_id:, amount: Helpers::Constants::MASS_EROSION, engine: nil, **)
                eng = engine || gravity_engine
                result = eng.erode_attractor(attractor_id, amount: amount)

                if result[:error]
                  log.warn "[cognitive_gravity] erode failed: #{result[:error]}"
                  return { success: false, **result }
                end

                log.debug "[cognitive_gravity] eroded id=#{attractor_id[0..7]} " \
                          "mass=#{result[:mass]} collapsed=#{result[:collapsed]}"
                { success: true, **result }
              end

              def strongest_attractors(limit: 5, engine: nil, **)
                eng = engine || gravity_engine
                attractors = eng.strongest_attractors(limit: limit)
                log.debug "[cognitive_gravity] strongest_attractors count=#{attractors.size}"
                { success: true, attractors: attractors.map(&:to_h), count: attractors.size }
              end

              def thought_distribution(engine: nil, **)
                eng = engine || gravity_engine
                distribution = eng.thought_distribution
                { success: true, distribution: distribution }
              end

              def cognitive_density_map(engine: nil, **)
                eng = engine || gravity_engine
                density_map = eng.cognitive_density_map
                { success: true, density_map: density_map }
              end

              def gravity_report(engine: nil, **)
                eng = engine || gravity_engine
                report = eng.gravity_report
                log.debug "[cognitive_gravity] report: attractors=#{report[:total_attractors]} " \
                          "orbiting=#{report[:total_orbiting]} supermassive=#{report[:supermassive_count]}"
                { success: true, report: report }
              end

              private

              def gravity_engine
                @gravity_engine ||= Helpers::GravityEngine.new
              end
            end
          end
        end
      end
    end
  end
end

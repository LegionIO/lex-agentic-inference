# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Gravity
          module Helpers
            class GravityEngine
              attr_reader :attractors, :orbiting_thoughts, :capture_events, :escape_events

              def initialize
                @attractors = {}
                @orbiting_thoughts = {}
                @capture_events   = []
                @escape_events    = []
              end

              def add_attractor(content:, domain: :unknown, mass: Constants::DEFAULT_MASS,
                                pull_radius: 1.0, decay_rate: 0.01)
                return { error: :capacity_exceeded, max: Constants::MAX_ATTRACTORS } if at_attractor_capacity?

                attractor = Attractor.new(
                  content:     content,
                  domain:      domain,
                  mass:        mass,
                  pull_radius: pull_radius,
                  decay_rate:  decay_rate
                )
                @attractors[attractor.id] = attractor
                attractor
              end

              def add_orbiting_thought(content:, attractor_id:, orbital_distance: 1.0, velocity: 0.0)
                return { error: :attractor_not_found } unless @attractors.key?(attractor_id)
                return { error: :capacity_exceeded, max: Constants::MAX_ORBITING } if at_orbiting_capacity?

                thought = OrbitingThought.new(
                  content:          content,
                  attractor_id:     attractor_id,
                  orbital_distance: orbital_distance,
                  velocity:         velocity
                )
                @orbiting_thoughts[thought.id] = thought
                thought
              end

              def simulate_tick
                captures = []
                escapes  = []

                @attractors.each_value do |attractor|
                  next if attractor.collapsed?

                  thoughts_for(attractor.id).each do |thought|
                    pull = attractor.pull_strength_at(distance: thought.orbital_distance)
                    next unless pull.positive?

                    was_captured = thought.captured?
                    was_escaped  = thought.escaped?

                    thought.approach!(pull)

                    if !was_captured && thought.captured?
                      event = build_event(:capture, attractor, thought)
                      captures << event
                      @capture_events << event
                    end

                    next unless !was_escaped && thought.escaped?

                    event = build_event(:escape, attractor, thought)
                    escapes << event
                    @escape_events << event
                  end
                end

                { captures: captures, escapes: escapes, tick_processed: true }
              end

              def accrete_attractor(attractor_id, amount: Constants::MASS_ACCRETION)
                attractor = @attractors[attractor_id]
                return { error: :not_found } unless attractor

                attractor.accrete!(amount)
                { accreted: true, id: attractor_id, mass: attractor.mass }
              end

              def erode_attractor(attractor_id, amount: Constants::MASS_EROSION)
                attractor = @attractors[attractor_id]
                return { error: :not_found } unless attractor

                attractor.erode!(amount)
                { eroded: true, id: attractor_id, mass: attractor.mass, collapsed: attractor.collapsed? }
              end

              def strongest_attractors(limit: 5)
                @attractors.values
                           .reject(&:collapsed?)
                           .sort_by { |a| -a.mass }
                           .first(limit)
              end

              def thought_distribution
                @attractors.transform_values { |a| thoughts_for(a.id).size }
              end

              def cognitive_density_map
                thought_distribution.transform_values do |count|
                  Constants.label_for(Constants::DENSITY_LABELS, count)
                end
              end

              def gravity_report
                collapsed, active = @attractors.values.partition(&:collapsed?)
                supermass = @attractors.values.select(&:supermassive?)
                captured  = @orbiting_thoughts.values.select(&:captured?)
                escaped   = @orbiting_thoughts.values.select(&:escaped?)

                {
                  total_attractors:     @attractors.size,
                  active_attractors:    active.size,
                  collapsed_attractors: collapsed.size,
                  supermassive_count:   supermass.size,
                  total_orbiting:       @orbiting_thoughts.size,
                  captured_count:       captured.size,
                  escaped_count:        escaped.size,
                  total_captures:       @capture_events.size,
                  total_escapes:        @escape_events.size,
                  strongest:            strongest_attractors(limit: 3).map(&:to_h)
                }
              end

              private

              def thoughts_for(attractor_id)
                @orbiting_thoughts.values.select { |t| t.attractor_id == attractor_id }
              end

              def at_attractor_capacity?
                @attractors.size >= Constants::MAX_ATTRACTORS
              end

              def at_orbiting_capacity?
                @orbiting_thoughts.size >= Constants::MAX_ORBITING
              end

              def build_event(type, attractor, thought)
                {
                  type:         type,
                  attractor_id: attractor.id,
                  thought_id:   thought.id,
                  mass:         attractor.mass,
                  distance:     thought.orbital_distance,
                  at:           Time.now.utc
                }
              end
            end
          end
        end
      end
    end
  end
end

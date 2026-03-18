# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Momentum
          module Helpers
            class Idea
              include Constants

              attr_reader :id, :content, :idea_type, :domain, :mass, :velocity,
                          :reinforcement_count, :challenge_count, :created_at, :last_updated_at

              def initialize(content:, idea_type:, domain:, mass: DEFAULT_MASS)
                @id                  = SecureRandom.uuid
                @content             = content
                @idea_type           = idea_type
                @domain              = domain
                @mass                = mass.clamp(MASS_FLOOR, MASS_CEILING)
                @velocity            = DEFAULT_VELOCITY
                @reinforcement_count = 0
                @challenge_count     = 0
                @created_at          = Time.now.utc
                @last_updated_at     = @created_at
              end

              def momentum
                @mass * @velocity
              end

              def momentum_label
                MOMENTUM_LABELS.find { |range, _| range.cover?(momentum) }&.last || :coasting
              end

              def inertia_label
                INERTIA_LABELS.find { |range, _| range.cover?(@mass) }&.last || :moderate
              end

              def reinforce!
                @reinforcement_count += 1
                @mass     = (@mass + REINFORCE_MASS_BOOST).clamp(MASS_FLOOR, MASS_CEILING)
                @velocity = (@velocity + REINFORCE_VELOCITY_BOOST).clamp(VELOCITY_FLOOR, VELOCITY_CEILING)
                @last_updated_at = Time.now.utc
              end

              def challenge!
                @challenge_count += 1
                @velocity = (@velocity - CHALLENGE_VELOCITY_PENALTY).clamp(VELOCITY_FLOOR, VELOCITY_CEILING)
                @mass     = (@mass - CHALLENGE_MASS_REDUCTION).clamp(MASS_FLOOR, MASS_CEILING)
                @last_updated_at = Time.now.utc
              end

              def apply_force(force:)
                acceleration = force / @mass
                @velocity = (@velocity + acceleration).clamp(VELOCITY_FLOOR, VELOCITY_CEILING)
                @last_updated_at = Time.now.utc
              end

              def apply_friction!
                return if @velocity.zero?

                @velocity = if @velocity.positive?
                              [(@velocity - FRICTION_RATE), 0.0].max
                            else
                              [(@velocity + FRICTION_RATE), 0.0].min
                            end
                @last_updated_at = Time.now.utc
              end

              def surging?
                momentum >= 0.5
              end

              def reversing?
                momentum <= -0.2
              end

              def at_rest?
                @velocity.abs < 0.01
              end

              def entrenched?
                @mass >= 0.8
              end

              def to_h
                {
                  id:                  @id,
                  content:             @content,
                  idea_type:           @idea_type,
                  domain:              @domain,
                  mass:                @mass,
                  velocity:            @velocity,
                  momentum:            momentum,
                  momentum_label:      momentum_label,
                  inertia_label:       inertia_label,
                  reinforcement_count: @reinforcement_count,
                  challenge_count:     @challenge_count,
                  created_at:          @created_at,
                  last_updated_at:     @last_updated_at
                }
              end
            end
          end
        end
      end
    end
  end
end

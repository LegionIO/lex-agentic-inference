# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Momentum
          module Helpers
            module Constants
              # Idea categories
              IDEA_TYPES = %i[belief goal hypothesis plan intuition].freeze

              # Momentum = mass * velocity
              # Mass = importance/entrenchment (resists change)
              # Velocity = rate of change/spread

              DEFAULT_MASS     = 0.5
              DEFAULT_VELOCITY = 0.0
              MASS_FLOOR       = 0.1
              MASS_CEILING     = 1.0
              VELOCITY_FLOOR   = -1.0
              VELOCITY_CEILING = 1.0

              # Friction reduces velocity each cycle
              FRICTION_RATE = 0.05

              # Force needed to change velocity (F = m * a, so a = F / m)
              # Higher mass = more force needed to accelerate
              MIN_FORCE = 0.01

              # Reinforcement increases mass (entrenchment)
              REINFORCE_MASS_BOOST = 0.05
              REINFORCE_VELOCITY_BOOST = 0.1

              # Challenge reduces velocity and slightly reduces mass
              CHALLENGE_VELOCITY_PENALTY = 0.15
              CHALLENGE_MASS_REDUCTION   = 0.02

              # Momentum labels
              MOMENTUM_LABELS = {
                (0.5..)      => :surging,
                (0.2...0.5)  => :building,
                (0.0...0.2)  => :coasting,
                (-0.2...0.0) => :slowing,
                (..-0.2)     => :reversing
              }.freeze

              # Inertia labels (based on mass)
              INERTIA_LABELS = {
                (0.8..)     => :immovable,
                (0.6...0.8) => :entrenched,
                (0.4...0.6) => :moderate,
                (0.2...0.4) => :flexible,
                (..0.2)     => :volatile
              }.freeze

              MAX_IDEAS   = 200
              MAX_HISTORY = 500
            end
          end
        end
      end
    end
  end
end

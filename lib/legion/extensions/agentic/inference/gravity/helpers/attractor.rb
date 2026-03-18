# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Gravity
          module Helpers
            class Attractor
              attr_reader :id, :content, :domain, :mass, :pull_radius, :decay_rate, :created_at, :reinforcement_count

              def initialize(content:, domain: :unknown, mass: Constants::DEFAULT_MASS,
                             pull_radius: 1.0, decay_rate: 0.01)
                @id                  = SecureRandom.uuid
                @content             = content
                @domain              = domain
                @mass                = mass.to_f.round(10)
                @pull_radius         = pull_radius.clamp(0.01, Float::INFINITY)
                @decay_rate          = decay_rate.clamp(0.0, 1.0)
                @created_at          = Time.now.utc
                @reinforcement_count = 0
              end

              def accrete!(amount = Constants::MASS_ACCRETION)
                @mass = (@mass + amount.to_f).round(10)
                @reinforcement_count += 1
                self
              end

              def erode!(amount = Constants::MASS_EROSION)
                @mass = [(@mass - amount.to_f).round(10), 0.0].max
                self
              end

              def pull_strength_at(distance:)
                return 0.0 if distance <= 0 || distance > @pull_radius

                raw = (Constants::PULL_CONSTANT * @mass) / (distance**2)
                raw.clamp(0.0, @mass)
              end

              def collapsed?
                @mass < Constants::COLLAPSE_THRESHOLD
              end

              def supermassive?
                @mass >= Constants::SUPERMASSIVE_THRESHOLD
              end

              def mass_label
                Constants.label_for(Constants::MASS_LABELS, @mass)
              end

              def to_h
                {
                  id:                  @id,
                  content:             @content,
                  domain:              @domain,
                  mass:                @mass,
                  pull_radius:         @pull_radius,
                  decay_rate:          @decay_rate,
                  reinforcement_count: @reinforcement_count,
                  collapsed:           collapsed?,
                  supermassive:        supermassive?,
                  mass_label:          mass_label,
                  created_at:          @created_at
                }
              end
            end
          end
        end
      end
    end
  end
end

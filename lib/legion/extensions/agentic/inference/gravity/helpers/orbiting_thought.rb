# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Gravity
          module Helpers
            class OrbitingThought
              attr_reader :id, :content, :attractor_id, :orbital_distance, :velocity, :created_at

              def initialize(content:, attractor_id:, orbital_distance: 1.0, velocity: 0.0)
                @id               = SecureRandom.uuid
                @content          = content
                @attractor_id     = attractor_id
                @orbital_distance = orbital_distance.clamp(0.0, Float::INFINITY).round(10)
                @velocity         = velocity.to_f.round(10)
                @created_at       = Time.now.utc
              end

              def approach!(delta)
                @orbital_distance = [(@orbital_distance - delta.abs).round(10), 0.0].max
                self
              end

              def escape!(delta)
                @orbital_distance = (@orbital_distance + delta.abs).round(10)
                self
              end

              def captured?
                @orbital_distance < Constants::CAPTURE_RADIUS
              end

              def escaped?
                @orbital_distance > Constants::ESCAPE_RADIUS
              end

              def orbit_label
                Constants.label_for(Constants::ORBIT_LABELS, @orbital_distance)
              end

              def to_h
                {
                  id:               @id,
                  content:          @content,
                  attractor_id:     @attractor_id,
                  orbital_distance: @orbital_distance,
                  velocity:         @velocity,
                  captured:         captured?,
                  escaped:          escaped?,
                  orbit_label:      orbit_label,
                  created_at:       @created_at
                }
              end
            end
          end
        end
      end
    end
  end
end

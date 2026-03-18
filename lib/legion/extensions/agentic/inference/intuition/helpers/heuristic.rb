# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Intuition
          module Helpers
            class Heuristic
              include Constants

              attr_reader :id, :name, :heuristic_type, :domain, :uses, :successes

              def initialize(id:, name:, heuristic_type:, domain: :general)
                @id             = id
                @name           = name
                @heuristic_type = resolve_type(heuristic_type)
                @domain         = domain
                @uses           = 0
                @successes      = 0
              end

              def apply
                @uses += 1
              end

              def record_outcome(success:)
                @successes += 1 if success
              end

              def success_rate
                return 0.0 if @uses.zero?

                @successes.to_f / @uses
              end

              def effective?
                @uses >= 3 && success_rate >= 0.6
              end

              def to_h
                {
                  id:             @id,
                  name:           @name,
                  heuristic_type: @heuristic_type,
                  domain:         @domain,
                  uses:           @uses,
                  successes:      @successes,
                  success_rate:   success_rate.round(4),
                  effective:      effective?
                }
              end

              private

              def resolve_type(type)
                sym = type.to_sym
                HEURISTIC_TYPES.include?(sym) ? sym : :fast_and_frugal
              end
            end
          end
        end
      end
    end
  end
end

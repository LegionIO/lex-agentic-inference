# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Affordance
          module Actor
            class Scan < Legion::Extensions::Actors::Every
              def time
                30
              end

              def use_runner?
                false
              end

              def runner_function
                :update_affordances
              end

              def runner_class
                Legion::Extensions::Agentic::Inference::Affordance::Runners::Affordance
              end
            end
          end
        end
      end
    end
  end
end

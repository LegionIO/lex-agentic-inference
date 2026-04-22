# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Momentum
          module Actor
            class UpdateCognitiveMomentum < Legion::Extensions::Actors::Every
              def runner_class
                Legion::Extensions::Agentic::Inference::Momentum::Runners::CognitiveMomentum
              end

              def runner_function
                'update_cognitive_momentum'
              end

              def time
                60
              end

              def run_now?
                false
              end

              def use_runner?
                false
              end

              def check_subtask?
                false
              end

              def generate_task?
                false
              end
            end
          end
        end
      end
    end
  end
end

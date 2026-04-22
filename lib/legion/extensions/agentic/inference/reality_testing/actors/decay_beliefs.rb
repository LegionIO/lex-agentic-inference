# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Inference
        module RealityTesting
          module Actor
            class DecayBeliefs < Legion::Extensions::Actors::Every
              def runner_class
                Legion::Extensions::Agentic::Inference::RealityTesting::Runners::RealityTesting
              end

              def runner_function
                'decay_beliefs'
              end

              def time
                300
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

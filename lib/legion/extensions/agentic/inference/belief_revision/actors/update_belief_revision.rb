# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Inference
        module BeliefRevision
          module Actor
            class UpdateBeliefRevision < Legion::Extensions::Actors::Every
              def runner_class
                Legion::Extensions::Agentic::Inference::BeliefRevision::Runners::BeliefRevision
              end

              def runner_function
                'update_belief_revision'
              end

              def time
                120
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

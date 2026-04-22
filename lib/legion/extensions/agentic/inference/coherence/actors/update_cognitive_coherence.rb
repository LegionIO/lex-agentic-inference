# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Coherence
          module Actor
            class UpdateCognitiveCoherence < Legion::Extensions::Actors::Every
              def runner_class
                Legion::Extensions::Agentic::Inference::Coherence::Runners::CognitiveCoherence
              end

              def runner_function
                'update_cognitive_coherence'
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

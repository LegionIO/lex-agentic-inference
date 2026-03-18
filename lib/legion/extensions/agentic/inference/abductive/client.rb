# frozen_string_literal: true

require 'legion/extensions/agentic/inference/abductive/helpers/constants'
require 'legion/extensions/agentic/inference/abductive/helpers/observation'
require 'legion/extensions/agentic/inference/abductive/helpers/hypothesis'
require 'legion/extensions/agentic/inference/abductive/helpers/abduction_engine'
require 'legion/extensions/agentic/inference/abductive/runners/abductive_reasoning'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Abductive
          class Client
            include Runners::AbductiveReasoning

            def initialize(engine: nil)
              @engine = engine || Helpers::AbductionEngine.new
            end
          end
        end
      end
    end
  end
end

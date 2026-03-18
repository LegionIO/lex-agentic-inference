# frozen_string_literal: true

require 'legion/extensions/agentic/inference/debugging/helpers/constants'
require 'legion/extensions/agentic/inference/debugging/helpers/reasoning_error'
require 'legion/extensions/agentic/inference/debugging/helpers/causal_trace'
require 'legion/extensions/agentic/inference/debugging/helpers/correction'
require 'legion/extensions/agentic/inference/debugging/helpers/debugging_engine'
require 'legion/extensions/agentic/inference/debugging/runners/cognitive_debugging'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Debugging
          class Client
            include Runners::CognitiveDebugging

            def initialize(engine: nil, **)
              @engine = engine || Helpers::DebuggingEngine.new
            end

            private

            attr_reader :engine
          end
        end
      end
    end
  end
end

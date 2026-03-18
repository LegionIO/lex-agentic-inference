# frozen_string_literal: true

require 'legion/extensions/agentic/inference/enactive_cognition/helpers/sensorimotor_loop'
require 'legion/extensions/agentic/inference/enactive_cognition/helpers/enaction_engine'
require 'legion/extensions/agentic/inference/enactive_cognition/runners/enactive_cognition'

module Legion
  module Extensions
    module Agentic
      module Inference
        module EnactiveCognition
          class Client
            include Runners::EnactiveCognition

            def initialize(**)
              @enaction_engine = Helpers::EnactionEngine.new
            end

            private

            attr_reader :enaction_engine
          end
        end
      end
    end
  end
end

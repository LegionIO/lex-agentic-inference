# frozen_string_literal: true

require 'legion/extensions/agentic/inference/horizon/helpers/constants'
require 'legion/extensions/agentic/inference/horizon/helpers/projection'
require 'legion/extensions/agentic/inference/horizon/helpers/horizon_engine'
require 'legion/extensions/agentic/inference/horizon/runners/cognitive_horizon'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Horizon
          class Client
            include Runners::CognitiveHorizon

            def initialize(**)
              @horizon_engine = Helpers::HorizonEngine.new
            end

            private

            attr_reader :horizon_engine
          end
        end
      end
    end
  end
end

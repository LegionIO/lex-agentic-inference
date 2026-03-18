# frozen_string_literal: true

require 'legion/extensions/agentic/inference/reality_testing/helpers/constants'
require 'legion/extensions/agentic/inference/reality_testing/helpers/belief'
require 'legion/extensions/agentic/inference/reality_testing/helpers/reality_engine'
require 'legion/extensions/agentic/inference/reality_testing/runners/reality_testing'

module Legion
  module Extensions
    module Agentic
      module Inference
        module RealityTesting
          class Client
            include Runners::RealityTesting

            def initialize(**)
              @reality_engine = Helpers::RealityEngine.new
            end

            private

            attr_reader :reality_engine
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'legion/extensions/agentic/inference/uncertainty_tolerance/helpers/constants'
require 'legion/extensions/agentic/inference/uncertainty_tolerance/helpers/decision'
require 'legion/extensions/agentic/inference/uncertainty_tolerance/helpers/tolerance_engine'
require 'legion/extensions/agentic/inference/uncertainty_tolerance/runners/uncertainty_tolerance'

module Legion
  module Extensions
    module Agentic
      module Inference
        module UncertaintyTolerance
          class Client
            include Runners::UncertaintyTolerance

            def initialize(**)
              @engine = Helpers::ToleranceEngine.new
            end

            private

            attr_reader :engine
          end
        end
      end
    end
  end
end

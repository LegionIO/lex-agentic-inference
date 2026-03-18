# frozen_string_literal: true

require 'legion/extensions/agentic/inference/hypothesis_testing/helpers/constants'
require 'legion/extensions/agentic/inference/hypothesis_testing/helpers/hypothesis'
require 'legion/extensions/agentic/inference/hypothesis_testing/helpers/hypothesis_engine'
require 'legion/extensions/agentic/inference/hypothesis_testing/runners/hypothesis_testing'

module Legion
  module Extensions
    module Agentic
      module Inference
        module HypothesisTesting
          class Client
            include Runners::HypothesisTesting

            def initialize(**)
              @hypothesis_engine = Helpers::HypothesisEngine.new
            end

            private

            attr_reader :hypothesis_engine
          end
        end
      end
    end
  end
end

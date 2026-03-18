# frozen_string_literal: true

require 'legion/extensions/agentic/inference/predictive_processing/helpers/constants'
require 'legion/extensions/agentic/inference/predictive_processing/helpers/generative_model'
require 'legion/extensions/agentic/inference/predictive_processing/helpers/predictive_processor'
require 'legion/extensions/agentic/inference/predictive_processing/runners/predictive_processing'

module Legion
  module Extensions
    module Agentic
      module Inference
        module PredictiveProcessing
          class Client
            include Runners::PredictiveProcessing

            def initialize(processor: nil)
              @default_processor = processor || Helpers::PredictiveProcessor.new
            end

            private

            attr_reader :default_processor
          end
        end
      end
    end
  end
end

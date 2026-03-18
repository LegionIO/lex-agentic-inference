# frozen_string_literal: true

require 'legion/extensions/agentic/inference/predictive_coding/helpers/constants'
require 'legion/extensions/agentic/inference/predictive_coding/helpers/prediction_error'
require 'legion/extensions/agentic/inference/predictive_coding/helpers/generative_model'
require 'legion/extensions/agentic/inference/predictive_coding/runners/predictive_coding'

module Legion
  module Extensions
    module Agentic
      module Inference
        module PredictiveCoding
          class Client
            include Runners::PredictiveCoding

            def initialize(generative_model: nil, **)
              @generative_model = generative_model || Helpers::GenerativeModel.new
            end

            private

            attr_reader :generative_model
          end
        end
      end
    end
  end
end

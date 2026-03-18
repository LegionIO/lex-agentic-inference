# frozen_string_literal: true

require 'legion/extensions/agentic/inference/prediction/helpers/modes'
require 'legion/extensions/agentic/inference/prediction/helpers/prediction_store'
require 'legion/extensions/agentic/inference/prediction/runners/prediction'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Prediction
          class Client
            include Runners::Prediction

            def initialize(**)
              @prediction_store = Helpers::PredictionStore.new
            end

            private

            attr_reader :prediction_store
          end
        end
      end
    end
  end
end

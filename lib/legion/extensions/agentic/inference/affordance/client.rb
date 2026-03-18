# frozen_string_literal: true

require 'legion/extensions/agentic/inference/affordance/helpers/constants'
require 'legion/extensions/agentic/inference/affordance/helpers/affordance_item'
require 'legion/extensions/agentic/inference/affordance/helpers/affordance_field'
require 'legion/extensions/agentic/inference/affordance/runners/affordance'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Affordance
          class Client
            include Runners::Affordance

            def initialize(field: nil, **)
              @field = field || Helpers::AffordanceField.new
            end

            private

            attr_reader :field
          end
        end
      end
    end
  end
end

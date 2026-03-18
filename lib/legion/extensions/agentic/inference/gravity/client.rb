# frozen_string_literal: true

require 'legion/extensions/agentic/inference/gravity/helpers/constants'
require 'legion/extensions/agentic/inference/gravity/helpers/attractor'
require 'legion/extensions/agentic/inference/gravity/helpers/orbiting_thought'
require 'legion/extensions/agentic/inference/gravity/helpers/gravity_engine'
require 'legion/extensions/agentic/inference/gravity/runners/gravity'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Gravity
          class Client
            include Runners::Gravity

            def initialize(**)
              @gravity_engine = Helpers::GravityEngine.new
            end

            private

            attr_reader :gravity_engine
          end
        end
      end
    end
  end
end

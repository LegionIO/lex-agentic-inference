# frozen_string_literal: true

require 'legion/extensions/agentic/inference/magnet/helpers/constants'
require 'legion/extensions/agentic/inference/magnet/helpers/pole'
require 'legion/extensions/agentic/inference/magnet/helpers/field'
require 'legion/extensions/agentic/inference/magnet/helpers/magnet_engine'
require 'legion/extensions/agentic/inference/magnet/runners/cognitive_magnet'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Magnet
          class Client
            include Runners::CognitiveMagnet

            def initialize(**)
              @magnet_engine = Helpers::MagnetEngine.new
            end

            private

            attr_reader :magnet_engine
          end
        end
      end
    end
  end
end

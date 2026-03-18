# frozen_string_literal: true

require 'legion/extensions/agentic/inference/schema/helpers/constants'
require 'legion/extensions/agentic/inference/schema/helpers/causal_relation'
require 'legion/extensions/agentic/inference/schema/helpers/world_model'
require 'legion/extensions/agentic/inference/schema/runners/schema'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Schema
          class Client
            include Runners::Schema

            attr_reader :world_model

            def initialize(world_model: nil, **)
              @world_model = world_model || Helpers::WorldModel.new
            end
          end
        end
      end
    end
  end
end

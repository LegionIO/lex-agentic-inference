# frozen_string_literal: true

require 'legion/extensions/agentic/inference/analogical/helpers/constants'
require 'legion/extensions/agentic/inference/analogical/helpers/structure_map'
require 'legion/extensions/agentic/inference/analogical/helpers/analogy_engine'
require 'legion/extensions/agentic/inference/analogical/runners/analogical_reasoning'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Analogical
          class Client
            include Runners::AnalogicalReasoning

            def initialize(engine: nil, **)
              @engine = engine || Helpers::AnalogyEngine.new
            end

            private

            attr_reader :engine
          end
        end
      end
    end
  end
end

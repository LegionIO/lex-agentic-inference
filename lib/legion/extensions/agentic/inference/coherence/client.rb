# frozen_string_literal: true

require 'legion/extensions/agentic/inference/coherence/helpers/constants'
require 'legion/extensions/agentic/inference/coherence/helpers/proposition'
require 'legion/extensions/agentic/inference/coherence/helpers/coherence_engine'
require 'legion/extensions/agentic/inference/coherence/runners/cognitive_coherence'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Coherence
          class Client
            include Runners::CognitiveCoherence

            def initialize(**)
              @engine = Helpers::CoherenceEngine.new
            end

            private

            attr_reader :engine
          end
        end
      end
    end
  end
end

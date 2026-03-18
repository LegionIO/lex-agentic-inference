# frozen_string_literal: true

require 'legion/extensions/agentic/inference/causal_reasoning/helpers/constants'
require 'legion/extensions/agentic/inference/causal_reasoning/helpers/causal_edge'
require 'legion/extensions/agentic/inference/causal_reasoning/helpers/causal_graph'
require 'legion/extensions/agentic/inference/causal_reasoning/runners/causal_reasoning'

module Legion
  module Extensions
    module Agentic
      module Inference
        module CausalReasoning
          class Client
            include Runners::CausalReasoning

            def initialize(graph: nil, **)
              @graph = graph
            end
          end
        end
      end
    end
  end
end

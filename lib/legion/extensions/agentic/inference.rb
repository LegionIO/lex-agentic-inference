# frozen_string_literal: true

require_relative 'inference/version'
require_relative 'inference/coherence'
require_relative 'inference/debugging'
require_relative 'inference/horizon'
require_relative 'inference/gravity'
require_relative 'inference/momentum'
require_relative 'inference/abductive'
require_relative 'inference/analogical'
require_relative 'inference/argument_mapping'
require_relative 'inference/bayesian'
require_relative 'inference/belief_revision'
require_relative 'inference/causal_attribution'
require_relative 'inference/causal_reasoning'
require_relative 'inference/counterfactual'
require_relative 'inference/hypothesis_testing'
require_relative 'inference/prediction'
require_relative 'inference/predictive_coding'
require_relative 'inference/predictive_processing'
require_relative 'inference/free_energy'
require_relative 'inference/intuition'
require_relative 'inference/schema'
require_relative 'inference/expectation_violation'
require_relative 'inference/uncertainty_tolerance'
require_relative 'inference/reality_testing'
require_relative 'inference/affordance'
require_relative 'inference/enactive_cognition'
require_relative 'inference/perceptual_inference'
require_relative 'inference/magnet'

module Legion
  module Extensions
    module Agentic
      module Inference
        extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core, false

        def self.remote_invocable?
          false
        end

        def self.mcp_tools?
          false
        end

        def self.mcp_tools_deferred?
          false
        end

        def self.transport_required?
          false
        end
      end
    end
  end
end

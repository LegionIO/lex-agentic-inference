# frozen_string_literal: true

require 'legion/extensions/agentic/inference/bayesian/helpers/constants'
require 'legion/extensions/agentic/inference/bayesian/helpers/belief'
require 'legion/extensions/agentic/inference/bayesian/helpers/belief_network'
require 'legion/extensions/agentic/inference/bayesian/runners/bayesian_belief'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Bayesian
          class Client
            include Runners::BayesianBelief

            def initialize(**)
              @belief_network = Helpers::BeliefNetwork.new
            end

            private

            attr_reader :belief_network
          end
        end
      end
    end
  end
end

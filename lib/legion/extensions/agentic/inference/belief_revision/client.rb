# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module BeliefRevision
          class Client
            include Runners::BeliefRevision

            def initialize(network: nil)
              @network = network || Helpers::BeliefNetwork.new
            end
          end
        end
      end
    end
  end
end

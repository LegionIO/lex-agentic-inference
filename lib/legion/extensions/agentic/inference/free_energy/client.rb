# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module FreeEnergy
          class Client
            include Runners::FreeEnergy

            def initialize(engine: nil)
              @engine = engine
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Intuition
          class Client
            include Runners::Intuition

            def initialize(engine: nil)
              @engine = engine || Helpers::IntuitionEngine.new
            end
          end
        end
      end
    end
  end
end

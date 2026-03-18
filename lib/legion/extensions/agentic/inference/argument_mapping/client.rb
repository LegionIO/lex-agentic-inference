# frozen_string_literal: true

require_relative 'runners/argument_mapping'

module Legion
  module Extensions
    module Agentic
      module Inference
        module ArgumentMapping
          class Client
            include Runners::ArgumentMapping

            def initialize(**); end
          end
        end
      end
    end
  end
end

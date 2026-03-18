# frozen_string_literal: true

require_relative 'belief_revision/version'
require_relative 'belief_revision/helpers/constants'
require_relative 'belief_revision/helpers/belief'
require_relative 'belief_revision/helpers/belief_network'
require_relative 'belief_revision/helpers/evidence'
require_relative 'belief_revision/runners/belief_revision'
require_relative 'belief_revision/client'

module Legion
  module Extensions
    module Agentic
      module Inference
        module BeliefRevision
          # Sub-module for belief revision: AGM contraction, expansion, and revision
        end
      end
    end
  end
end

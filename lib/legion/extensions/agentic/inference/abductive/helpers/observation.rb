# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Abductive
          module Helpers
            class Observation
              attr_reader :id, :content, :domain, :surprise_level, :context, :created_at

              def initialize(content:, domain:, surprise_level: :notable, context: {})
                @id             = SecureRandom.uuid
                @content        = content
                @domain         = domain
                @surprise_level = surprise_level
                @context        = context
                @created_at     = Time.now.utc
              end

              def to_h
                {
                  id:             @id,
                  content:        @content,
                  domain:         @domain,
                  surprise_level: @surprise_level,
                  context:        @context,
                  created_at:     @created_at
                }
              end
            end
          end
        end
      end
    end
  end
end

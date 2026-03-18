# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module Gravity
          module Helpers
            module Constants
              MAX_ATTRACTORS   = 200
              MAX_ORBITING     = 500
              DEFAULT_MASS     = 1.0
              MASS_ACCRETION   = 0.15
              MASS_EROSION     = 0.05
              CAPTURE_RADIUS   = 0.2
              ESCAPE_RADIUS    = 1.5
              PULL_CONSTANT    = 0.1
              COLLAPSE_THRESHOLD     = 0.1
              SUPERMASSIVE_THRESHOLD = 3.0

              ATTRACTOR_DOMAINS = %i[
                problem
                curiosity
                anxiety
                obsession
                interest
                fear
                desire
                unknown
              ].freeze

              MASS_LABELS = {
                (0.0..0.1)             => :collapsing,
                (0.1..0.5)             => :weak,
                (0.5..1.0)             => :nascent,
                (1.0..2.0)             => :moderate,
                (2.0..3.0)             => :strong,
                (3.0..Float::INFINITY) => :supermassive
              }.freeze

              DENSITY_LABELS = {
                (0..0)                => :empty,
                (1..2)                => :sparse,
                (3..5)                => :light,
                (6..10)               => :moderate,
                (11..20)              => :dense,
                (21..Float::INFINITY) => :crowded
              }.freeze

              ORBIT_LABELS = {
                (0.0..0.2)             => :captured,
                (0.2..0.5)             => :tight,
                (0.5..1.0)             => :stable,
                (1.0..1.5)             => :loose,
                (1.5..Float::INFINITY) => :escaped
              }.freeze

              module_function

              def label_for(labels_hash, value)
                labels_hash.each do |range, label|
                  return label if range.cover?(value)
                end
                :unknown
              end

              def valid_domain?(domain)
                ATTRACTOR_DOMAINS.include?(domain)
              end
            end
          end
        end
      end
    end
  end
end

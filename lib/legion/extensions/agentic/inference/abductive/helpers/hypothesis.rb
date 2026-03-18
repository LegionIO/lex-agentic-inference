# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Inference
        module Abductive
          module Helpers
            class Hypothesis
              include Constants

              attr_reader :id, :content, :observation_ids, :domain,
                          :simplicity, :explanatory_power, :prior_probability,
                          :evidence_for, :evidence_against, :state,
                          :created_at, :last_evaluated_at
              attr_accessor :plausibility

              SUPPORT_EVIDENCE_THRESHOLD = 3

              def initialize(content:, observation_ids:, domain:, simplicity:, explanatory_power:,
                             prior_probability: Constants::DEFAULT_PLAUSIBILITY)
                @id                 = SecureRandom.uuid
                @content            = content
                @observation_ids    = Array(observation_ids)
                @domain             = domain
                @plausibility       = prior_probability
                @simplicity         = simplicity
                @explanatory_power  = explanatory_power
                @prior_probability  = prior_probability
                @evidence_for       = 0
                @evidence_against   = 0
                @state              = :candidate
                @created_at         = Time.now.utc
                @last_evaluated_at  = Time.now.utc
              end

              def overall_score
                (Constants::SIMPLICITY_WEIGHT * @simplicity) +
                  (Constants::EXPLANATORY_POWER_WEIGHT * @explanatory_power) +
                  (Constants::PRIOR_WEIGHT * @prior_probability)
              end

              def add_evidence(supporting:)
                @last_evaluated_at = Time.now.utc
                if supporting
                  @evidence_for += 1
                  @plausibility = (@plausibility + Constants::EVIDENCE_BOOST).clamp(
                    Constants::PLAUSIBILITY_FLOOR,
                    Constants::PLAUSIBILITY_CEILING
                  )
                else
                  @evidence_against += 1
                  @plausibility = (@plausibility - Constants::CONTRADICTION_PENALTY).clamp(
                    Constants::PLAUSIBILITY_FLOOR,
                    Constants::PLAUSIBILITY_CEILING
                  )
                end
                support! if @evidence_for >= SUPPORT_EVIDENCE_THRESHOLD && @state == :candidate
              end

              def refute!
                @state = :refuted
                @last_evaluated_at = Time.now.utc
              end

              def support!
                @state = :supported
                @last_evaluated_at = Time.now.utc
              end

              def quality_label
                score = overall_score
                Constants::QUALITY_LABELS.each do |range, label|
                  return label if range.include?(score)
                end
                :implausible
              end

              def to_h
                {
                  id:                @id,
                  content:           @content,
                  observation_ids:   @observation_ids,
                  domain:            @domain,
                  plausibility:      @plausibility,
                  simplicity:        @simplicity,
                  explanatory_power: @explanatory_power,
                  prior_probability: @prior_probability,
                  evidence_for:      @evidence_for,
                  evidence_against:  @evidence_against,
                  state:             @state,
                  overall_score:     overall_score,
                  quality_label:     quality_label,
                  created_at:        @created_at,
                  last_evaluated_at: @last_evaluated_at
                }
              end
            end
          end
        end
      end
    end
  end
end

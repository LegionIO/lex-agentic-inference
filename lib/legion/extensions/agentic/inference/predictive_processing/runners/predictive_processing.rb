# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module PredictiveProcessing
          module Runners
            module PredictiveProcessing
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex)

              def add_generative_model(domain:, **)
                return { added: false, reason: :missing_domain } if domain.nil? || domain.to_s.strip.empty?

                result = default_processor.add_model(domain: domain.to_sym)
                log.debug "[predictive_processing] add_model domain=#{domain} added=#{result[:added]}"
                result
              end

              def predict_from_model(domain:, context: {}, **)
                return { predicted: false, reason: :missing_domain } if domain.nil?

                prediction = default_processor.predict(domain: domain.to_sym, context: context)
                log.debug "[predictive_processing] predict domain=#{domain} " \
                          "expected=#{prediction[:expected_value]&.round(3)}"
                { predicted: true, domain: domain, prediction: prediction }
              end

              def observe_outcome(domain:, actual:, predicted:, **)
                return { observed: false, reason: :missing_domain } if domain.nil?

                result = default_processor.observe(
                  domain:    domain.to_sym,
                  actual:    actual,
                  predicted: predicted
                )
                log_observe(domain, result)
                result
              end

              def inference_mode(domain:, **)
                return { mode: nil, reason: :missing_domain } if domain.nil?

                mode = default_processor.inference_mode(domain.to_sym)
                log.debug "[predictive_processing] inference_mode domain=#{domain} mode=#{mode}"
                { domain: domain, mode: mode }
              end

              def free_energy(domain: nil, **)
                if domain
                  fe = default_processor.free_energy_for(domain.to_sym)
                  return { domain: domain, free_energy: nil, reason: :domain_not_found } if fe.nil?

                  { domain: domain, free_energy: fe }
                else
                  { global_free_energy: default_processor.global_free_energy }
                end
              end

              def models_needing_update(**)
                needing = default_processor.models_needing_update
                log.debug "[predictive_processing] models_needing_update count=#{needing.size}"
                { count: needing.size, models: needing }
              end

              def active_inference_candidates(**)
                candidates = default_processor.active_inference_candidates
                log.debug "[predictive_processing] active_inference_candidates count=#{candidates.size}"
                { count: candidates.size, domains: candidates }
              end

              def update_predictive_processing(**)
                default_processor.tick
                log.debug '[predictive_processing] tick: precision decayed on all models'
                { ticked: true, model_count: default_processor.models.size }
              end

              def predictive_processing_stats(**)
                stats = default_processor.to_h
                log.debug "[predictive_processing] stats global_fe=#{stats[:global_free_energy]&.round(3)}"
                { success: true, stats: stats }
              end

              private

              def default_processor
                @default_processor ||= Helpers::PredictiveProcessor.new
              end

              def log_observe(domain, result)
                return unless result[:observed]

                log.debug "[predictive_processing] observe domain=#{domain} " \
                          "error=#{result[:prediction_error]&.round(3)} " \
                          "mode=#{result[:inference_mode]}"
              end
            end
          end
        end
      end
    end
  end
end

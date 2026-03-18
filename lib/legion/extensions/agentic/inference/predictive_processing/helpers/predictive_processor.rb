# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Inference
        module PredictiveProcessing
          module Helpers
            class PredictiveProcessor
              include Constants

              attr_reader :models

              def initialize
                @models = {}
              end

              def add_model(domain:)
                return { added: false, reason: :limit_reached } if @models.size >= MAX_MODELS
                return { added: false, reason: :already_exists } if @models.key?(domain)

                model = GenerativeModel.new(domain: domain)
                @models[domain] = model
                { added: true, domain: domain, model_id: model.id }
              end

              def predict(domain:, context: {})
                model = find_or_create(domain)
                model.predict(context: context)
              end

              def observe(domain:, actual:, predicted:)
                model = @models[domain]
                return { observed: false, reason: :domain_not_found } unless model

                error = model.observe(actual: actual, predicted: predicted)
                mode  = inference_mode(domain)

                model.update_model(error: error) if %i[perceptual hybrid].include?(mode)

                {
                  observed:         true,
                  domain:           domain,
                  prediction_error: error,
                  inference_mode:   mode,
                  free_energy:      model.free_energy,
                  state:            model.state
                }
              end

              def inference_mode(domain)
                model = @models[domain]
                return :perceptual unless model

                fe = model.free_energy
                determine_mode(fe, model.precision)
              end

              def free_energy_for(domain)
                model = @models[domain]
                model&.free_energy
              end

              def global_free_energy
                return 0.0 if @models.empty?

                total = @models.values.sum(&:free_energy)
                total / @models.size
              end

              def precision_weight(domain)
                model = @models[domain]
                model ? model.precision : DEFAULT_PRECISION
              end

              def models_needing_update
                @models.select { |_d, m| m.surprised? }.transform_values(&:to_h)
              end

              def stable_models
                @models.select { |_d, m| m.stable? }.transform_values(&:to_h)
              end

              def active_inference_candidates
                @models.select { |_d, m| m.free_energy > ACTIVE_INFERENCE_THRESHOLD }
                       .keys
              end

              def tick
                @models.each_value(&:decay)
              end

              def to_h
                {
                  model_count:              @models.size,
                  global_free_energy:       global_free_energy,
                  models_needing_update:    models_needing_update.size,
                  stable_model_count:       stable_models.size,
                  active_inference_domains: active_inference_candidates.size,
                  models:                   @models.transform_values(&:to_h)
                }
              end

              private

              def find_or_create(domain)
                @models[domain] ||= begin
                  model           = GenerativeModel.new(domain: domain)
                  @models[domain] = model if @models.size < MAX_MODELS
                  model
                end
              end

              def determine_mode(free_energy, precision)
                if free_energy > FREE_ENERGY_THRESHOLD && precision >= ACTIVE_INFERENCE_THRESHOLD
                  :hybrid
                elsif free_energy > ACTIVE_INFERENCE_THRESHOLD
                  :active
                else
                  :perceptual
                end
              end
            end
          end
        end
      end
    end
  end
end

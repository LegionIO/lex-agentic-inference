# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::PredictiveProcessing::Runners::PredictiveProcessing do
  let(:client) { Legion::Extensions::Agentic::Inference::PredictiveProcessing::Client.new }

  describe '#add_generative_model' do
    it 'adds a model for a valid domain' do
      result = client.add_generative_model(domain: :perception)
      expect(result[:added]).to be true
      expect(result[:domain]).to eq(:perception)
    end

    it 'returns error for nil domain' do
      result = client.add_generative_model(domain: nil)
      expect(result[:added]).to be false
      expect(result[:reason]).to eq(:missing_domain)
    end

    it 'returns error for empty string domain' do
      result = client.add_generative_model(domain: '')
      expect(result[:added]).to be false
      expect(result[:reason]).to eq(:missing_domain)
    end

    it 'returns model_id on success' do
      result = client.add_generative_model(domain: :with_id)
      expect(result[:model_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'rejects duplicate domain' do
      client.add_generative_model(domain: :dup)
      result = client.add_generative_model(domain: :dup)
      expect(result[:added]).to be false
      expect(result[:reason]).to eq(:already_exists)
    end
  end

  describe '#predict_from_model' do
    before { client.add_generative_model(domain: :action) }

    it 'returns a prediction for known domain' do
      result = client.predict_from_model(domain: :action, context: {})
      expect(result[:predicted]).to be true
    end

    it 'includes domain in result' do
      result = client.predict_from_model(domain: :action)
      expect(result[:domain]).to eq(:action)
    end

    it 'includes prediction hash' do
      result = client.predict_from_model(domain: :action, context: { val: 1 })
      expect(result[:prediction]).to be_a(Hash)
      expect(result[:prediction][:expected_value]).to be_a(Float)
    end

    it 'returns error for nil domain' do
      result = client.predict_from_model(domain: nil)
      expect(result[:predicted]).to be false
      expect(result[:reason]).to eq(:missing_domain)
    end

    it 'auto-creates model for unknown domain' do
      result = client.predict_from_model(domain: :auto_created, context: {})
      expect(result[:predicted]).to be true
    end
  end

  describe '#observe_outcome' do
    before { client.add_generative_model(domain: :vision) }

    it 'returns observed: true for known domain' do
      result = client.observe_outcome(domain: :vision, actual: 0.7, predicted: 0.5)
      expect(result[:observed]).to be true
    end

    it 'includes inference_mode' do
      result = client.observe_outcome(domain: :vision, actual: 0.6, predicted: 0.5)
      expect(Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::Constants::INFERENCE_MODES)
        .to include(result[:inference_mode])
    end

    it 'returns error for nil domain' do
      result = client.observe_outcome(domain: nil, actual: 0.5, predicted: 0.5)
      expect(result[:observed]).to be false
      expect(result[:reason]).to eq(:missing_domain)
    end

    it 'returns false for unknown domain' do
      result = client.observe_outcome(domain: :unknown_x, actual: 0.5, predicted: 0.5)
      expect(result[:observed]).to be false
    end

    it 'includes free_energy in result' do
      result = client.observe_outcome(domain: :vision, actual: 0.9, predicted: 0.1)
      expect(result[:free_energy]).to be_a(Float)
    end
  end

  describe '#inference_mode' do
    it 'returns mode for known domain' do
      client.add_generative_model(domain: :motor)
      result = client.inference_mode(domain: :motor)
      expect(result[:domain]).to eq(:motor)
      expect(Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::Constants::INFERENCE_MODES)
        .to include(result[:mode])
    end

    it 'returns error for nil domain' do
      result = client.inference_mode(domain: nil)
      expect(result[:mode]).to be_nil
      expect(result[:reason]).to eq(:missing_domain)
    end

    it 'returns :perceptual for unknown domain' do
      result = client.inference_mode(domain: :unregistered)
      expect(result[:mode]).to eq(:perceptual)
    end
  end

  describe '#free_energy' do
    it 'returns global free energy when no domain given' do
      result = client.free_energy
      expect(result).to have_key(:global_free_energy)
    end

    it 'returns domain free energy when domain given' do
      client.add_generative_model(domain: :fe_domain)
      result = client.free_energy(domain: :fe_domain)
      expect(result[:domain]).to eq(:fe_domain)
      expect(result[:free_energy]).to be_a(Float)
    end

    it 'returns not_found for unknown domain' do
      result = client.free_energy(domain: :no_such)
      expect(result[:reason]).to eq(:domain_not_found)
    end
  end

  describe '#models_needing_update' do
    it 'returns count and models hash' do
      result = client.models_needing_update
      expect(result).to have_key(:count)
      expect(result).to have_key(:models)
    end

    it 'returns 0 when no models exist' do
      expect(client.models_needing_update[:count]).to eq(0)
    end

    it 'returns surprised models' do
      client.add_generative_model(domain: :volatile)
      5.times { client.observe_outcome(domain: :volatile, actual: 1.0, predicted: 0.0) }
      result = client.models_needing_update
      expect(result[:count]).to be >= 1
    end
  end

  describe '#active_inference_candidates' do
    it 'returns count and domains array' do
      result = client.active_inference_candidates
      expect(result).to have_key(:count)
      expect(result).to have_key(:domains)
    end

    it 'returns 0 when no high-free-energy models' do
      expect(client.active_inference_candidates[:count]).to eq(0)
    end

    it 'includes domains with high free energy' do
      client.add_generative_model(domain: :erratic)
      5.times { client.observe_outcome(domain: :erratic, actual: 1.0, predicted: 0.0) }
      result = client.active_inference_candidates
      expect(result[:domains]).to include(:erratic)
    end
  end

  describe '#update_predictive_processing' do
    it 'ticks the processor' do
      result = client.update_predictive_processing
      expect(result[:ticked]).to be true
    end

    it 'reports model count' do
      client.add_generative_model(domain: :tracked)
      result = client.update_predictive_processing
      expect(result[:model_count]).to eq(1)
    end
  end

  describe '#predictive_processing_stats' do
    it 'returns success: true' do
      result = client.predictive_processing_stats
      expect(result[:success]).to be true
    end

    it 'returns stats hash' do
      result = client.predictive_processing_stats
      expect(result[:stats]).to be_a(Hash)
    end

    it 'includes global_free_energy in stats' do
      result = client.predictive_processing_stats
      expect(result[:stats]).to have_key(:global_free_energy)
    end

    it 'reflects added models in stats' do
      client.add_generative_model(domain: :counted)
      result = client.predictive_processing_stats
      expect(result[:stats][:model_count]).to eq(1)
    end
  end
end

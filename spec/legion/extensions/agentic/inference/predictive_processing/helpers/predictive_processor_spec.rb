# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::PredictiveProcessor do
  subject(:processor) { described_class.new }

  describe '#add_model' do
    it 'adds a new model for a domain' do
      result = processor.add_model(domain: :perception)
      expect(result[:added]).to be true
      expect(result[:domain]).to eq(:perception)
    end

    it 'returns model_id on success' do
      result = processor.add_model(domain: :cognition)
      expect(result[:model_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'rejects duplicate domains' do
      processor.add_model(domain: :dup)
      result = processor.add_model(domain: :dup)
      expect(result[:added]).to be false
      expect(result[:reason]).to eq(:already_exists)
    end

    it 'rejects when at model limit' do
      20.times { |i| processor.add_model(domain: :"domain_#{i}") }
      result = processor.add_model(domain: :overflow)
      expect(result[:added]).to be false
      expect(result[:reason]).to eq(:limit_reached)
    end
  end

  describe '#predict' do
    it 'returns a prediction hash for a known domain' do
      processor.add_model(domain: :action)
      result = processor.predict(domain: :action, context: { urgency: 0.8 })
      expect(result[:expected_value]).to be_a(Float)
    end

    it 'auto-creates model for unknown domain (within limit)' do
      result = processor.predict(domain: :new_domain, context: {})
      expect(result[:expected_value]).to be_a(Float)
    end

    it 'includes domain in prediction' do
      result = processor.predict(domain: :emotion, context: {})
      expect(result[:domain]).to eq(:emotion)
    end
  end

  describe '#observe' do
    before { processor.add_model(domain: :vision) }

    it 'returns observed: true for known domain' do
      result = processor.observe(domain: :vision, actual: 0.7, predicted: 0.5)
      expect(result[:observed]).to be true
    end

    it 'returns prediction_error' do
      result = processor.observe(domain: :vision, actual: 0.8, predicted: 0.5)
      expect(result[:prediction_error]).to be_a(Float)
    end

    it 'returns inference_mode' do
      result = processor.observe(domain: :vision, actual: 0.8, predicted: 0.5)
      expect(described_class::INFERENCE_MODES).to include(result[:inference_mode])
    end

    it 'returns observed: false for unknown domain' do
      result = processor.observe(domain: :unknown, actual: 0.5, predicted: 0.5)
      expect(result[:observed]).to be false
      expect(result[:reason]).to eq(:domain_not_found)
    end

    it 'returns free_energy after observation' do
      result = processor.observe(domain: :vision, actual: 1.0, predicted: 0.0)
      expect(result[:free_energy]).to be_a(Float)
    end
  end

  describe '#inference_mode' do
    it 'returns :perceptual for unknown domain' do
      expect(processor.inference_mode(:nonexistent)).to eq(:perceptual)
    end

    it 'returns a valid inference mode for known domain' do
      processor.add_model(domain: :memory)
      mode = processor.inference_mode(:memory)
      expect(described_class::INFERENCE_MODES).to include(mode)
    end

    it 'returns :active or :hybrid when free energy is high' do
      processor.add_model(domain: :surprise)
      5.times { processor.observe(domain: :surprise, actual: 1.0, predicted: 0.0) }
      mode = processor.inference_mode(:surprise)
      expect(%i[active hybrid]).to include(mode)
    end
  end

  describe '#free_energy_for' do
    it 'returns nil for unknown domain' do
      expect(processor.free_energy_for(:unknown)).to be_nil
    end

    it 'returns a float for known domain' do
      processor.add_model(domain: :planning)
      expect(processor.free_energy_for(:planning)).to be_a(Float)
    end
  end

  describe '#global_free_energy' do
    it 'returns 0.0 with no models' do
      expect(processor.global_free_energy).to eq(0.0)
    end

    it 'returns average free energy across models' do
      processor.add_model(domain: :d1)
      processor.add_model(domain: :d2)
      expect(processor.global_free_energy).to be_a(Float)
    end
  end

  describe '#precision_weight' do
    it 'returns DEFAULT_PRECISION for unknown domain' do
      expect(processor.precision_weight(:unknown)).to eq(described_class::DEFAULT_PRECISION)
    end

    it 'returns model precision for known domain' do
      processor.add_model(domain: :known)
      expect(processor.precision_weight(:known)).to be_a(Float)
    end
  end

  describe '#models_needing_update' do
    it 'returns empty hash when all models are stable' do
      expect(processor.models_needing_update).to be_empty
    end

    it 'returns domains with high free energy' do
      processor.add_model(domain: :erratic)
      5.times { processor.observe(domain: :erratic, actual: 1.0, predicted: 0.0) }
      needing = processor.models_needing_update
      expect(needing).to have_key(:erratic)
    end
  end

  describe '#stable_models' do
    it 'returns all models initially (all stable)' do
      processor.add_model(domain: :calm)
      expect(processor.stable_models).to have_key(:calm)
    end

    it 'excludes surprised models' do
      processor.add_model(domain: :upset)
      5.times { processor.observe(domain: :upset, actual: 1.0, predicted: 0.0) }
      expect(processor.stable_models).not_to have_key(:upset)
    end
  end

  describe '#active_inference_candidates' do
    it 'returns empty array when all models have low free energy' do
      expect(processor.active_inference_candidates).to be_empty
    end

    it 'returns domains exceeding active inference threshold' do
      processor.add_model(domain: :high_fe)
      5.times { processor.observe(domain: :high_fe, actual: 1.0, predicted: 0.0) }
      expect(processor.active_inference_candidates).to include(:high_fe)
    end
  end

  describe '#tick' do
    it 'decays precision on all models' do
      processor.add_model(domain: :tickable)
      before = processor.models[:tickable].precision
      processor.tick
      expect(processor.models[:tickable].precision).to be < before
    end

    it 'does not raise with no models' do
      expect { processor.tick }.not_to raise_error
    end
  end

  describe '#to_h' do
    it 'includes model_count' do
      processor.add_model(domain: :counted)
      expect(processor.to_h[:model_count]).to eq(1)
    end

    it 'includes global_free_energy' do
      expect(processor.to_h[:global_free_energy]).to be_a(Float)
    end

    it 'includes models hash' do
      processor.add_model(domain: :listed)
      expect(processor.to_h[:models]).to have_key(:listed)
    end

    it 'includes counts for needing update and stable' do
      h = processor.to_h
      expect(h).to have_key(:models_needing_update)
      expect(h).to have_key(:stable_model_count)
    end
  end
end

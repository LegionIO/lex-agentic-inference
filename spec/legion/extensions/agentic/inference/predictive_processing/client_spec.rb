# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::PredictiveProcessing::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a client with a default processor' do
      expect(client).to be_a(described_class)
    end

    it 'accepts an injected processor' do
      processor = Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::PredictiveProcessor.new
      injected  = described_class.new(processor: processor)
      result    = injected.predictive_processing_stats
      expect(result[:success]).to be true
    end
  end

  describe 'full workflow: add -> predict -> observe -> stats' do
    it 'completes a full predictive processing cycle' do
      client.add_generative_model(domain: :workflow)
      prediction = client.predict_from_model(domain: :workflow, context: { step: 1 })
      expect(prediction[:predicted]).to be true

      expected_val = prediction[:prediction][:expected_value]
      obs          = client.observe_outcome(domain: :workflow, actual: 0.8, predicted: expected_val)
      expect(obs[:observed]).to be true

      stats = client.predictive_processing_stats
      expect(stats[:stats][:model_count]).to eq(1)
    end

    it 'accumulates free energy after repeated high errors' do
      client.add_generative_model(domain: :stress)
      5.times { client.observe_outcome(domain: :stress, actual: 1.0, predicted: 0.0) }
      fe = client.free_energy(domain: :stress)
      expect(fe[:free_energy]).to be > 0.0
    end

    it 'identifies active inference candidate after surprise' do
      client.add_generative_model(domain: :act_candidate)
      5.times { client.observe_outcome(domain: :act_candidate, actual: 1.0, predicted: 0.0) }
      result = client.active_inference_candidates
      expect(result[:domains]).to include(:act_candidate)
    end

    it 'tick decays precision over time' do
      client.add_generative_model(domain: :decaying)
      initial_weight = client.instance_variable_get(:@default_processor).precision_weight(:decaying)
      client.update_predictive_processing
      after_weight = client.instance_variable_get(:@default_processor).precision_weight(:decaying)
      expect(after_weight).to be < initial_weight
    end
  end

  describe 'constants' do
    it 'exposes INFERENCE_MODES' do
      expect(Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::Constants::INFERENCE_MODES)
        .to eq(%i[perceptual active hybrid])
    end

    it 'exposes MODEL_STATES' do
      expect(Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::Constants::MODEL_STATES)
        .to eq(%i[stable updating exploring surprised])
    end

    it 'exposes FREE_ENERGY_THRESHOLD' do
      expect(Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::Constants::FREE_ENERGY_THRESHOLD)
        .to eq(0.7)
    end

    it 'exposes ACTIVE_INFERENCE_THRESHOLD' do
      expect(Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::Constants::ACTIVE_INFERENCE_THRESHOLD)
        .to eq(0.5)
    end

    it 'exposes all PRECISION_LABELS keys as ranges' do
      labels = Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::Constants::PRECISION_LABELS
      expect(labels.values).to include(:certain, :confident, :uncertain, :vague, :noise)
    end
  end
end

# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::PredictiveProcessing::Helpers::GenerativeModel do
  subject(:model) { described_class.new(domain: :test_domain) }

  describe '#initialize' do
    it 'assigns a unique id' do
      expect(model.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets domain' do
      expect(model.domain).to eq(:test_domain)
    end

    it 'sets default confidence' do
      expect(model.confidence).to eq(described_class::DEFAULT_PRECISION)
    end

    it 'sets default precision' do
      expect(model.precision).to eq(described_class::DEFAULT_PRECISION)
    end

    it 'starts with zero prediction error' do
      expect(model.prediction_error).to eq(0.0)
    end

    it 'starts in stable state' do
      expect(model.state).to eq(:stable)
    end

    it 'records created_at timestamp' do
      expect(model.created_at).to be_a(Time)
    end

    it 'records updated_at timestamp' do
      expect(model.updated_at).to be_a(Time)
    end
  end

  describe '#predict' do
    it 'returns a prediction hash' do
      result = model.predict(context: {})
      expect(result).to be_a(Hash)
    end

    it 'includes expected_value' do
      result = model.predict(context: {})
      expect(result[:expected_value]).to be_a(Float)
    end

    it 'includes confidence' do
      result = model.predict(context: {})
      expect(result[:confidence]).to eq(model.confidence)
    end

    it 'includes domain' do
      result = model.predict(context: {})
      expect(result[:domain]).to eq(:test_domain)
    end

    it 'applies context richness bonus' do
      sparse_pred = model.predict(context: {})
      rich_pred   = model.predict(context: { a: 1, b: 2, c: 3, d: 4, e: 5 })
      expect(rich_pred[:expected_value]).to be >= sparse_pred[:expected_value]
    end

    it 'caps expected_value at 1.0' do
      result = model.predict(context: (1..20).to_h { |i| [i, i] })
      expect(result[:expected_value]).to be <= 1.0
    end

    it 'stores the prediction as last_prediction' do
      model.predict(context: { key: :val })
      expect(model.last_prediction).not_to be_nil
    end

    it 'uses default empty context when none provided' do
      result = model.predict
      expect(result[:context_size]).to eq(0)
    end
  end

  describe '#observe' do
    it 'returns a numeric error magnitude' do
      error = model.observe(actual: 0.8, predicted: 0.5)
      expect(error).to be_a(Float)
    end

    it 'computes absolute difference' do
      error = model.observe(actual: 0.8, predicted: 0.5)
      expect(error).to be_within(0.01).of(0.3)
    end

    it 'clamps error to 0..1' do
      error = model.observe(actual: 5.0, predicted: 0.0)
      expect(error).to eq(1.0)
    end

    it 'returns 0.0 for non-numeric inputs' do
      error = model.observe(actual: 'abc', predicted: 0.5)
      expect(error).to eq(0.0)
    end

    it 'updates updated_at' do
      before = model.updated_at
      sleep(0.01)
      model.observe(actual: 0.9, predicted: 0.1)
      expect(model.updated_at).to be >= before
    end
  end

  describe '#free_energy' do
    it 'returns 0.0 with no history' do
      expect(model.free_energy).to eq(0.0)
    end

    it 'returns a positive value after observations' do
      model.observe(actual: 1.0, predicted: 0.0)
      expect(model.free_energy).to be >= 0.0
    end

    it 'returns higher free energy for larger errors' do
      low_model  = described_class.new(domain: :low)
      high_model = described_class.new(domain: :high)
      low_model.observe(actual: 0.51, predicted: 0.5)
      high_model.observe(actual: 1.0, predicted: 0.0)
      expect(high_model.free_energy).to be > low_model.free_energy
    end
  end

  describe '#stable?' do
    it 'returns true when free_energy is low' do
      expect(model.stable?).to be true
    end

    it 'returns false when surprised' do
      5.times { model.observe(actual: 1.0, predicted: 0.0) }
      expect(model.stable?).to be false
    end
  end

  describe '#surprised?' do
    it 'returns false initially' do
      expect(model.surprised?).to be false
    end

    it 'returns true after repeated large errors' do
      5.times { model.observe(actual: 1.0, predicted: 0.0) }
      expect(model.surprised?).to be true
    end
  end

  describe '#update_model' do
    it 'adjusts confidence downward on positive error' do
      before = model.confidence
      model.update_model(error: 0.5)
      expect(model.confidence).to be < before
    end

    it 'does not drop confidence below MODEL_CONFIDENCE_FLOOR' do
      10.times { model.update_model(error: 1.0) }
      expect(model.confidence).to be >= described_class::MODEL_CONFIDENCE_FLOOR
    end

    it 'sets state to updating' do
      model.update_model(error: 0.3)
      expect(model.state).to eq(:updating)
    end
  end

  describe '#decay' do
    it 'reduces precision' do
      before = model.precision
      model.decay
      expect(model.precision).to be < before
    end

    it 'does not drop precision below PRECISION_FLOOR' do
      100.times { model.decay }
      expect(model.precision).to be >= described_class::PRECISION_FLOOR
    end
  end

  describe '#precision_label' do
    it 'returns :uncertain for default precision (0.5)' do
      expect(model.precision_label).to eq(:uncertain)
    end

    it 'returns :certain for high precision' do
      allow(model).to receive(:precision).and_return(0.9)
      expect(model.precision_label).to eq(:certain)
    end

    it 'returns :noise for very low precision' do
      allow(model).to receive(:precision).and_return(0.1)
      expect(model.precision_label).to eq(:noise)
    end

    it 'returns :vague for precision around 0.3' do
      allow(model).to receive(:precision).and_return(0.3)
      expect(model.precision_label).to eq(:vague)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all required keys' do
      h = model.to_h
      %i[id domain confidence precision prediction_error free_energy state
         precision_label stable surprised history_size created_at updated_at].each do |key|
        expect(h).to have_key(key)
      end
    end

    it 'reflects current model state' do
      model.observe(actual: 0.8, predicted: 0.3)
      h = model.to_h
      expect(h[:history_size]).to eq(1)
    end
  end
end

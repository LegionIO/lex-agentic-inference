# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::ExpectationViolation::Helpers::Expectation do
  subject(:expectation) { described_class.new(context: 'response_time', domain: :performance) }

  describe '#initialize' do
    it 'creates with defaults' do
      expect(expectation.context).to eq('response_time')
      expect(expectation.domain).to eq(:performance)
      expect(expectation.expected_value).to eq(0.5)
      expect(expectation.tolerance).to eq(0.2)
      expect(expectation.violation_count).to eq(0)
    end

    it 'generates a uuid' do
      expect(expectation.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'clamps expected value' do
      clamped = described_class.new(context: 'x', domain: :d, expected_value: 5.0)
      expect(clamped.expected_value).to eq(1.0)
    end
  end

  describe '#evaluate' do
    context 'when within tolerance' do
      it 'returns not violated' do
        result = expectation.evaluate(actual_value: 0.6)
        expect(result[:violated]).to be false
        expect(result[:type]).to eq(:neutral)
      end
    end

    context 'when positive violation' do
      it 'detects positive violation' do
        result = expectation.evaluate(actual_value: 0.9)
        expect(result[:violated]).to be true
        expect(result[:type]).to eq(:positive)
        expect(result[:arousal]).to be > 0
      end
    end

    context 'when negative violation' do
      it 'detects negative violation' do
        result = expectation.evaluate(actual_value: 0.1)
        expect(result[:violated]).to be true
        expect(result[:type]).to eq(:negative)
        expect(result[:arousal]).to be > 0
      end
    end

    it 'increments violation count on violation' do
      expectation.evaluate(actual_value: 0.9)
      expect(expectation.violation_count).to eq(1)
    end

    it 'does not increment on non-violation' do
      expectation.evaluate(actual_value: 0.5)
      expect(expectation.violation_count).to eq(0)
    end

    it 'returns arousal label' do
      result = expectation.evaluate(actual_value: 0.95)
      expect(result[:arousal_label]).to be_a(Symbol)
    end
  end

  describe '#adapt!' do
    it 'moves expected value toward actual' do
      expectation.adapt!(actual_value: 0.9)
      expect(expectation.expected_value).to be > 0.5
      expect(expectation.adaptation_count).to eq(1)
    end

    it 'moves gradually not instantly' do
      expectation.adapt!(actual_value: 1.0)
      expect(expectation.expected_value).to be < 1.0
    end
  end

  describe '#violation_label' do
    it 'returns label for positive deviation' do
      expect(expectation.violation_label(0.5)).to eq(:positive)
    end

    it 'returns label for negative deviation' do
      expect(expectation.violation_label(-0.5)).to eq(:negative)
    end

    it 'returns neutral for small deviation' do
      expect(expectation.violation_label(0.1)).to eq(:neutral)
    end
  end

  describe '#to_h' do
    it 'returns complete hash' do
      hash = expectation.to_h
      expect(hash).to include(:id, :context, :domain, :expected_value, :tolerance,
                              :violation_count, :adaptation_count)
    end
  end
end

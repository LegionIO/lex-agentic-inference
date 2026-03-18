# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::ExpectationViolation::Runners::ExpectationViolation do
  let(:client) { Legion::Extensions::Agentic::Inference::ExpectationViolation::Helpers::Client.new }

  describe '#create_expectation' do
    it 'creates an expectation' do
      result = client.create_expectation(context: 'test', domain: :perf)
      expect(result[:success]).to be true
      expect(result[:expectation][:context]).to eq('test')
    end
  end

  describe '#evaluate_expectation' do
    it 'evaluates against expectation' do
      created = client.create_expectation(context: 'x', domain: :d)
      result = client.evaluate_expectation(expectation_id: created[:expectation][:id], actual_value: 0.9)
      expect(result[:success]).to be true
      expect(result[:violated]).to be true
    end
  end

  describe '#adapt_expectation_value' do
    it 'adapts the expected value' do
      created = client.create_expectation(context: 'x', domain: :d)
      result = client.adapt_expectation_value(expectation_id: created[:expectation][:id], actual_value: 0.8)
      expect(result[:success]).to be true
    end
  end

  describe '#recent_violations_report' do
    it 'returns recent violations' do
      result = client.recent_violations_report(limit: 5)
      expect(result[:success]).to be true
    end
  end

  describe '#violations_by_type_report' do
    it 'filters by type' do
      result = client.violations_by_type_report(type: :positive)
      expect(result[:success]).to be true
    end
  end

  describe '#most_violated_expectations' do
    it 'returns most violated' do
      result = client.most_violated_expectations(limit: 3)
      expect(result[:success]).to be true
    end
  end

  describe '#expectation_violation_stats' do
    it 'returns stats' do
      result = client.expectation_violation_stats
      expect(result[:success]).to be true
      expect(result).to include(:total_expectations, :total_violations)
    end
  end
end

# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::ExpectationViolation::Helpers::ViolationEngine do
  subject(:engine) { described_class.new }

  let(:exp) { engine.create_expectation(context: 'response', domain: :perf) }

  describe '#create_expectation' do
    it 'creates and stores an expectation' do
      result = engine.create_expectation(context: 'latency', domain: :network)
      expect(result).to be_a(Legion::Extensions::Agentic::Inference::ExpectationViolation::Helpers::Expectation)
    end

    it 'records history' do
      engine.create_expectation(context: 'x', domain: :d)
      expect(engine.history.last[:event]).to eq(:created)
    end
  end

  describe '#evaluate_against' do
    it 'evaluates within tolerance' do
      result = engine.evaluate_against(expectation_id: exp.id, actual_value: 0.5)
      expect(result[:success]).to be true
      expect(result[:violated]).to be false
    end

    it 'detects positive violation' do
      result = engine.evaluate_against(expectation_id: exp.id, actual_value: 0.9)
      expect(result[:violated]).to be true
      expect(result[:type]).to eq(:positive)
    end

    it 'detects negative violation' do
      result = engine.evaluate_against(expectation_id: exp.id, actual_value: 0.1)
      expect(result[:violated]).to be true
      expect(result[:type]).to eq(:negative)
    end

    it 'returns not_found for missing' do
      result = engine.evaluate_against(expectation_id: 'missing', actual_value: 0.5)
      expect(result[:success]).to be false
    end

    it 'records violations' do
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.9)
      expect(engine.recent_violations.size).to eq(1)
    end
  end

  describe '#adapt_expectation' do
    it 'adapts the expected value' do
      result = engine.adapt_expectation(expectation_id: exp.id, actual_value: 0.8)
      expect(result[:success]).to be true
      expect(result[:new_expected]).to be > 0.5
    end

    it 'returns not_found for missing' do
      result = engine.adapt_expectation(expectation_id: 'missing', actual_value: 0.8)
      expect(result[:success]).to be false
    end
  end

  describe '#recent_violations' do
    it 'returns recent violations' do
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.9)
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.1)
      expect(engine.recent_violations(limit: 5).size).to eq(2)
    end
  end

  describe '#violations_by_type' do
    it 'filters by type' do
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.9)
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.1)
      expect(engine.violations_by_type(type: :positive).size).to eq(1)
    end
  end

  describe '#expectations_by_domain' do
    it 'filters by domain' do
      engine.create_expectation(context: 'a', domain: :net)
      engine.create_expectation(context: 'b', domain: :cpu)
      expect(engine.expectations_by_domain(domain: :net).size).to eq(1)
    end
  end

  describe '#most_violated' do
    it 'returns expectations sorted by violation count' do
      exp1 = engine.create_expectation(context: 'a', domain: :d)
      engine.create_expectation(context: 'b', domain: :d)
      3.times { engine.evaluate_against(expectation_id: exp1.id, actual_value: 0.9) }
      result = engine.most_violated(limit: 2)
      expect(result.first).to eq(exp1)
    end
  end

  describe '#violation_rate' do
    it 'computes rate of violations per evaluation' do
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.9)
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.5)
      expect(engine.violation_rate).to be_a(Float)
    end
  end

  describe '#positive_violation_ratio' do
    it 'computes ratio of positive violations' do
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.9)
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.1)
      expect(engine.positive_violation_ratio).to eq(0.5)
    end
  end

  describe '#to_h' do
    it 'returns stats hash' do
      exp
      stats = engine.to_h
      expect(stats).to include(:total_expectations, :total_violations,
                               :violation_rate, :positive_ratio, :history_count)
    end
  end

  describe '#prune_stale_violations' do
    it 'removes violations older than the cutoff' do
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.9)
      expect(engine.recent_violations.size).to eq(1)
      pruned = engine.prune_stale_violations(cutoff: Time.now.utc + 1)
      expect(pruned).to eq(1)
      expect(engine.recent_violations.size).to eq(0)
    end

    it 'keeps violations newer than the cutoff' do
      engine.evaluate_against(expectation_id: exp.id, actual_value: 0.9)
      pruned = engine.prune_stale_violations(cutoff: Time.now.utc - 3600)
      expect(pruned).to eq(0)
      expect(engine.recent_violations.size).to eq(1)
    end
  end
end

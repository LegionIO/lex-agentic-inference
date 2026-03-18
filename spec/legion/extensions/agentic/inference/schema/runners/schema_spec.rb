# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Inference::Schema::Runners::Schema do
  let(:wmodel) { Legion::Extensions::Agentic::Inference::Schema::Helpers::WorldModel.new }

  let(:host) do
    Object.new.tap do |obj|
      obj.extend(described_class)
      obj.instance_variable_set(:@world_model, wmodel)
    end
  end

  describe '#learn_relation' do
    it 'returns success for valid relation' do
      result = host.learn_relation(cause: :rain, effect: :wet, relation_type: :causes)
      expect(result[:success]).to be true
      expect(result[:relation][:cause]).to eq(:rain)
    end

    it 'returns failure for invalid type' do
      result = host.learn_relation(cause: :a, effect: :b, relation_type: :invalid)
      expect(result[:success]).to be false
    end

    it 'accepts string relation types' do
      result = host.learn_relation(cause: :rain, effect: :wet, relation_type: 'causes')
      expect(result[:success]).to be true
    end

    it 'reinforces on duplicate learn' do
      host.learn_relation(cause: :rain, effect: :wet, relation_type: :causes, confidence: 0.5)
      result = host.learn_relation(cause: :rain, effect: :wet, relation_type: :causes)
      expect(result[:relation][:evidence_count]).to eq(2)
    end
  end

  describe '#weaken_relation' do
    before { host.learn_relation(cause: :rain, effect: :wet, relation_type: :causes, confidence: 0.6) }

    it 'returns success' do
      result = host.weaken_relation(cause: :rain, effect: :wet, relation_type: :causes)
      expect(result[:success]).to be true
    end

    it 'returns failure for unknown relation' do
      result = host.weaken_relation(cause: :x, effect: :y, relation_type: :causes)
      expect(result[:success]).to be false
    end
  end

  describe '#explain' do
    before do
      host.learn_relation(cause: :rain, effect: :flood, relation_type: :causes, confidence: 0.8)
      host.learn_relation(cause: :flood, effect: :damage, relation_type: :causes, confidence: 0.7)
    end

    it 'returns an explanation chain' do
      result = host.explain(outcome: :damage)
      expect(result[:outcome]).to eq(:damage)
      expect(result[:chain]).not_to be_empty
    end

    it 'returns empty chain for unknown outcome' do
      result = host.explain(outcome: :unknown)
      expect(result[:chain]).to be_empty
    end
  end

  describe '#counterfactual' do
    before do
      host.learn_relation(cause: :rain, effect: :wet, relation_type: :causes)
      host.learn_relation(cause: :wet, effect: :slip, relation_type: :causes)
    end

    it 'traces downstream impact' do
      result = host.counterfactual(cause: :rain)
      expect(result[:cause]).to eq(:rain)
      expect(result[:affected].size).to be >= 2
    end
  end

  describe '#find_effects' do
    before { host.learn_relation(cause: :rain, effect: :wet, relation_type: :causes) }

    it 'returns effects for a cause' do
      result = host.find_effects(cause: :rain)
      expect(result[:count]).to eq(1)
      expect(result[:effects].first[:effect]).to eq(:wet)
    end
  end

  describe '#find_causes' do
    before { host.learn_relation(cause: :rain, effect: :flood, relation_type: :causes) }

    it 'returns causes for an effect' do
      result = host.find_causes(effect: :flood)
      expect(result[:count]).to eq(1)
      expect(result[:causes].first[:cause]).to eq(:rain)
    end
  end

  describe '#contradictions' do
    it 'detects contradictions' do
      host.learn_relation(cause: :a, effect: :b, relation_type: :causes, confidence: 0.8)
      host.learn_relation(cause: :a, effect: :b, relation_type: :prevents, confidence: 0.3)
      result = host.contradictions
      expect(result[:count]).to eq(1)
    end
  end

  describe '#schema_stats' do
    it 'returns stats with top relations' do
      host.learn_relation(cause: :a, effect: :b, relation_type: :causes, confidence: 0.95)
      result = host.schema_stats
      expect(result).to have_key(:relation_count)
      expect(result).to have_key(:top_relations)
    end
  end

  describe '#update_schema' do
    it 'returns world model summary' do
      result = host.update_schema(tick_results: {})
      expect(result).to have_key(:relation_count)
    end

    it 'extracts prediction outcomes' do
      tick = {
        prediction_engine: {
          resolved: [
            { domain: :weather, outcome_domain: :mood, accurate: true },
            { domain: :sleep, outcome_domain: :energy, accurate: false }
          ]
        }
      }
      host.update_schema(tick_results: tick)
      expect(wmodel.relation_count).to be >= 1
    end

    it 'handles empty tick results' do
      result = host.update_schema(tick_results: {})
      expect(result[:relation_count]).to eq(0)
    end
  end
end

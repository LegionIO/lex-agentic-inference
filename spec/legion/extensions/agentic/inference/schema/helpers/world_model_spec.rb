# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Inference::Schema::Helpers::WorldModel do
  subject(:model) { described_class.new }

  describe '#initialize' do
    it 'starts with empty relations' do
      expect(model.relations).to be_empty
    end
  end

  describe '#add_relation' do
    it 'creates a new causal relation' do
      result = model.add_relation(cause: :rain, effect: :wet, relation_type: :causes)
      expect(result).to be_a(Legion::Extensions::Agentic::Inference::Schema::Helpers::CausalRelation)
    end

    it 'reinforces existing relation on repeat add' do
      model.add_relation(cause: :rain, effect: :wet, relation_type: :causes, confidence: 0.5)
      result = model.add_relation(cause: :rain, effect: :wet, relation_type: :causes)
      expect(result.evidence_count).to eq(2)
      expect(result.confidence).to be > 0.5
    end

    it 'returns nil for invalid relation type' do
      expect(model.add_relation(cause: :a, effect: :b, relation_type: :invalid)).to be_nil
    end

    it 'increments relation count' do
      model.add_relation(cause: :rain, effect: :wet, relation_type: :causes)
      model.add_relation(cause: :sun, effect: :warm, relation_type: :causes)
      expect(model.relation_count).to eq(2)
    end
  end

  describe '#weaken_relation' do
    before { model.add_relation(cause: :rain, effect: :wet, relation_type: :causes, confidence: 0.6) }

    it 'reduces confidence' do
      result = model.weaken_relation(cause: :rain, effect: :wet, relation_type: :causes)
      expect(result.confidence).to be < 0.6
    end

    it 'returns nil for unknown relation' do
      expect(model.weaken_relation(cause: :x, effect: :y, relation_type: :causes)).to be_nil
    end

    it 'prunes relation if it falls below threshold' do
      model.weaken_relation(cause: :rain, effect: :wet, relation_type: :causes)
      model.weaken_relation(cause: :rain, effect: :wet, relation_type: :causes)
      model.weaken_relation(cause: :rain, effect: :wet, relation_type: :causes)
      model.weaken_relation(cause: :rain, effect: :wet, relation_type: :causes)
      expect(model.relation_count).to eq(0)
    end
  end

  describe '#find_effects' do
    before do
      model.add_relation(cause: :rain, effect: :wet, relation_type: :causes)
      model.add_relation(cause: :rain, effect: :flood, relation_type: :causes)
      model.add_relation(cause: :sun, effect: :warm, relation_type: :causes)
    end

    it 'returns effects for a given cause' do
      effects = model.find_effects(:rain)
      expect(effects.size).to eq(2)
      expect(effects.map(&:effect)).to contain_exactly(:wet, :flood)
    end

    it 'returns empty array for unknown cause' do
      expect(model.find_effects(:snow)).to be_empty
    end
  end

  describe '#find_causes' do
    before do
      model.add_relation(cause: :rain, effect: :flood, relation_type: :causes)
      model.add_relation(cause: :snowmelt, effect: :flood, relation_type: :causes)
    end

    it 'returns causes for a given effect' do
      causes = model.find_causes(:flood)
      expect(causes.size).to eq(2)
      expect(causes.map(&:cause)).to contain_exactly(:rain, :snowmelt)
    end
  end

  describe '#explain' do
    before do
      model.add_relation(cause: :rain, effect: :wet_ground, relation_type: :causes, confidence: 0.8)
      model.add_relation(cause: :wet_ground, effect: :slip, relation_type: :causes, confidence: 0.7)
      model.add_relation(cause: :slip, effect: :injury, relation_type: :causes, confidence: 0.6)
    end

    it 'builds an explanation chain' do
      chain = model.explain(:injury)
      expect(chain.size).to be >= 1
      expect(chain.first[:effect]).to eq(:injury)
    end

    it 'traces back to root cause' do
      chain = model.explain(:injury)
      causes_in_chain = chain.map { |c| c[:cause] }
      expect(causes_in_chain).to include(:slip)
    end

    it 'returns empty chain for unknown outcome' do
      expect(model.explain(:unknown)).to be_empty
    end
  end

  describe '#counterfactual' do
    before do
      model.add_relation(cause: :rain, effect: :wet, relation_type: :causes)
      model.add_relation(cause: :wet, effect: :slip, relation_type: :causes)
    end

    it 'traces downstream effects' do
      affected = model.counterfactual(:rain)
      effects = affected.map { |a| a[:effect] }
      expect(effects).to include(:wet)
      expect(effects).to include(:slip)
    end

    it 'returns empty for unknown cause' do
      expect(model.counterfactual(:unknown)).to be_empty
    end
  end

  describe '#contradictions' do
    it 'detects cause/prevent contradictions' do
      model.add_relation(cause: :exercise, effect: :health, relation_type: :causes, confidence: 0.8)
      model.add_relation(cause: :exercise, effect: :health, relation_type: :prevents, confidence: 0.3)
      result = model.contradictions
      expect(result.size).to eq(1)
      expect(result.first[:cause]).to eq(:exercise)
    end

    it 'returns empty when no contradictions' do
      model.add_relation(cause: :rain, effect: :wet, relation_type: :causes)
      expect(model.contradictions).to be_empty
    end
  end

  describe '#decay_all' do
    it 'decays all relations' do
      model.add_relation(cause: :a, effect: :b, relation_type: :causes, confidence: 0.5)
      model.decay_all
      rel = model.relations.values.first
      expect(rel.confidence).to be < 0.5
    end

    it 'prunes weak relations' do
      model.add_relation(cause: :a, effect: :b, relation_type: :causes, confidence: 0.05)
      model.decay_all
      expect(model.relation_count).to eq(0)
    end
  end

  describe '#domain_count' do
    it 'counts unique entities' do
      model.add_relation(cause: :a, effect: :b, relation_type: :causes)
      model.add_relation(cause: :b, effect: :c, relation_type: :causes)
      expect(model.domain_count).to eq(3)
    end
  end

  describe '#to_h' do
    it 'returns summary hash' do
      result = model.to_h
      expect(result).to have_key(:relation_count)
      expect(result).to have_key(:domain_count)
      expect(result).to have_key(:established_count)
      expect(result).to have_key(:contradiction_count)
    end
  end
end

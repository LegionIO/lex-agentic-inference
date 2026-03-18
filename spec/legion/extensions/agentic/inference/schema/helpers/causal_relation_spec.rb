# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Inference::Schema::Helpers::CausalRelation do
  subject(:relation) { described_class.new(cause: :rain, effect: :wet_ground, relation_type: :causes, confidence: 0.6) }

  describe '#initialize' do
    it 'sets cause and effect' do
      expect(relation.cause).to eq(:rain)
      expect(relation.effect).to eq(:wet_ground)
    end

    it 'sets relation type' do
      expect(relation.relation_type).to eq(:causes)
    end

    it 'clamps confidence to 0..1' do
      rel = described_class.new(cause: :a, effect: :b, relation_type: :causes, confidence: 5.0)
      expect(rel.confidence).to eq(1.0)
    end

    it 'generates a UUID' do
      expect(relation.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'starts with evidence count of 1' do
      expect(relation.evidence_count).to eq(1)
    end
  end

  describe '#reinforce' do
    it 'increases confidence' do
      initial = relation.confidence
      relation.reinforce
      expect(relation.confidence).to be > initial
    end

    it 'increments evidence count' do
      relation.reinforce
      expect(relation.evidence_count).to eq(2)
    end

    it 'caps confidence at 1.0' do
      20.times { relation.reinforce(0.1) }
      expect(relation.confidence).to eq(1.0)
    end
  end

  describe '#weaken' do
    it 'decreases confidence' do
      initial = relation.confidence
      relation.weaken
      expect(relation.confidence).to be < initial
    end

    it 'floors confidence at 0.0' do
      20.times { relation.weaken(0.1) }
      expect(relation.confidence).to eq(0.0)
    end
  end

  describe '#decay' do
    it 'reduces confidence by DECAY_RATE' do
      initial = relation.confidence
      relation.decay
      expect(relation.confidence).to be_within(0.001).of(initial - Legion::Extensions::Agentic::Inference::Schema::Helpers::Constants::DECAY_RATE)
    end
  end

  describe '#established?' do
    it 'returns true when confidence >= established threshold' do
      rel = described_class.new(cause: :a, effect: :b, relation_type: :causes, confidence: 0.95)
      expect(rel.established?).to be true
    end

    it 'returns false when confidence is moderate' do
      expect(relation.established?).to be false
    end
  end

  describe '#speculative?' do
    it 'returns true when confidence is very low' do
      rel = described_class.new(cause: :a, effect: :b, relation_type: :causes, confidence: 0.05)
      expect(rel.speculative?).to be true
    end
  end

  describe '#prunable?' do
    it 'returns true when confidence below PRUNE_THRESHOLD' do
      rel = described_class.new(cause: :a, effect: :b, relation_type: :causes, confidence: 0.05)
      expect(rel.prunable?).to be true
    end
  end

  describe '#to_h' do
    it 'returns a hash with expected keys' do
      result = relation.to_h
      expect(result).to have_key(:id)
      expect(result).to have_key(:cause)
      expect(result).to have_key(:effect)
      expect(result).to have_key(:relation_type)
      expect(result).to have_key(:confidence)
      expect(result).to have_key(:evidence_count)
      expect(result).to have_key(:established)
    end
  end
end

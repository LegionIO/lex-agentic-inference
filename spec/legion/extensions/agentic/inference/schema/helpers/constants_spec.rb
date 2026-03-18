# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Inference::Schema::Helpers::Constants do
  describe 'RELATION_TYPES' do
    it 'contains 6 types' do
      expect(described_class::RELATION_TYPES.size).to eq(6)
    end

    it 'is frozen' do
      expect(described_class::RELATION_TYPES).to be_frozen
    end

    %i[causes prevents enables requires correlates contradicts].each do |type|
      it "includes #{type}" do
        expect(described_class::RELATION_TYPES).to include(type)
      end
    end
  end

  describe 'CONFIDENCE_LEVELS' do
    it 'is ordered highest to lowest' do
      values = described_class::CONFIDENCE_LEVELS.values
      expect(values).to eq(values.sort.reverse)
    end
  end

  describe 'scalar constants' do
    it 'has SCHEMA_ALPHA between 0 and 1' do
      expect(described_class::SCHEMA_ALPHA).to be_between(0.0, 1.0)
    end

    it 'has positive MAX_SCHEMAS' do
      expect(described_class::MAX_SCHEMAS).to be > 0
    end

    it 'has REINFORCEMENT_BONUS between 0 and 1' do
      expect(described_class::REINFORCEMENT_BONUS).to be_between(0.0, 1.0)
    end

    it 'has CONTRADICTION_PENALTY between 0 and 1' do
      expect(described_class::CONTRADICTION_PENALTY).to be_between(0.0, 1.0)
    end

    it 'has DECAY_RATE between 0 and 1' do
      expect(described_class::DECAY_RATE).to be_between(0.0, 1.0)
    end

    it 'has PRUNE_THRESHOLD between 0 and 1' do
      expect(described_class::PRUNE_THRESHOLD).to be_between(0.0, 1.0)
    end
  end
end

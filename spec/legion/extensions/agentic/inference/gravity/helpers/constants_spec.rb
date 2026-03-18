# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Gravity::Helpers::Constants do
  describe 'numeric constants' do
    it 'defines MAX_ATTRACTORS' do
      expect(described_class::MAX_ATTRACTORS).to eq(200)
    end

    it 'defines MAX_ORBITING' do
      expect(described_class::MAX_ORBITING).to eq(500)
    end

    it 'defines DEFAULT_MASS' do
      expect(described_class::DEFAULT_MASS).to eq(1.0)
    end

    it 'defines MASS_ACCRETION' do
      expect(described_class::MASS_ACCRETION).to eq(0.15)
    end

    it 'defines MASS_EROSION' do
      expect(described_class::MASS_EROSION).to eq(0.05)
    end

    it 'defines CAPTURE_RADIUS' do
      expect(described_class::CAPTURE_RADIUS).to eq(0.2)
    end

    it 'defines ESCAPE_RADIUS' do
      expect(described_class::ESCAPE_RADIUS).to eq(1.5)
    end

    it 'defines PULL_CONSTANT' do
      expect(described_class::PULL_CONSTANT).to eq(0.1)
    end

    it 'defines COLLAPSE_THRESHOLD' do
      expect(described_class::COLLAPSE_THRESHOLD).to eq(0.1)
    end

    it 'defines SUPERMASSIVE_THRESHOLD' do
      expect(described_class::SUPERMASSIVE_THRESHOLD).to eq(3.0)
    end
  end

  describe 'ATTRACTOR_DOMAINS' do
    it 'contains 8 domains' do
      expect(described_class::ATTRACTOR_DOMAINS.size).to eq(8)
    end

    it 'includes expected domains' do
      expect(described_class::ATTRACTOR_DOMAINS).to include(:problem, :curiosity, :anxiety, :obsession)
      expect(described_class::ATTRACTOR_DOMAINS).to include(:interest, :fear, :desire, :unknown)
    end

    it 'is frozen' do
      expect(described_class::ATTRACTOR_DOMAINS).to be_frozen
    end
  end

  describe '.label_for' do
    it 'returns correct mass label for weak mass' do
      label = described_class.label_for(described_class::MASS_LABELS, 0.3)
      expect(label).to eq(:weak)
    end

    it 'returns correct mass label for supermassive' do
      label = described_class.label_for(described_class::MASS_LABELS, 4.0)
      expect(label).to eq(:supermassive)
    end

    it 'returns :unknown for a value not in any range' do
      label = described_class.label_for({}, 1.0)
      expect(label).to eq(:unknown)
    end

    it 'returns empty density label for zero thoughts' do
      label = described_class.label_for(described_class::DENSITY_LABELS, 0)
      expect(label).to eq(:empty)
    end

    it 'returns crowded density label for large count' do
      label = described_class.label_for(described_class::DENSITY_LABELS, 30)
      expect(label).to eq(:crowded)
    end

    it 'returns captured orbit label for very close distance' do
      label = described_class.label_for(described_class::ORBIT_LABELS, 0.05)
      expect(label).to eq(:captured)
    end

    it 'returns escaped orbit label for large distance' do
      label = described_class.label_for(described_class::ORBIT_LABELS, 2.0)
      expect(label).to eq(:escaped)
    end
  end

  describe '.valid_domain?' do
    it 'returns true for a valid domain' do
      expect(described_class.valid_domain?(:curiosity)).to be true
    end

    it 'returns false for an invalid domain' do
      expect(described_class.valid_domain?(:nonexistent)).to be false
    end
  end
end

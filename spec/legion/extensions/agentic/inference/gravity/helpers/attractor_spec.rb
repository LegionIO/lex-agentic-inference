# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Gravity::Helpers::Attractor do
  subject(:attractor) { described_class.new(content: 'test thought', domain: :curiosity) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(attractor.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets content' do
      expect(attractor.content).to eq('test thought')
    end

    it 'sets domain' do
      expect(attractor.domain).to eq(:curiosity)
    end

    it 'sets default mass' do
      expect(attractor.mass).to eq(1.0)
    end

    it 'accepts custom mass' do
      a = described_class.new(content: 'x', mass: 2.5)
      expect(a.mass).to eq(2.5)
    end

    it 'sets created_at' do
      expect(attractor.created_at).to be_a(Time)
    end

    it 'initializes reinforcement_count to 0' do
      expect(attractor.reinforcement_count).to eq(0)
    end
  end

  describe '#accrete!' do
    it 'increases mass by default accretion amount' do
      attractor.accrete!
      expect(attractor.mass).to be_within(0.001).of(1.15)
    end

    it 'increases mass by custom amount' do
      attractor.accrete!(0.5)
      expect(attractor.mass).to be_within(0.001).of(1.5)
    end

    it 'increments reinforcement_count' do
      attractor.accrete!
      expect(attractor.reinforcement_count).to eq(1)
    end

    it 'returns self for chaining' do
      expect(attractor.accrete!).to eq(attractor)
    end
  end

  describe '#erode!' do
    it 'decreases mass by default erosion amount' do
      attractor.erode!
      expect(attractor.mass).to be_within(0.001).of(0.95)
    end

    it 'does not go below zero' do
      a = described_class.new(content: 'x', mass: 0.03)
      a.erode!(0.1)
      expect(a.mass).to eq(0.0)
    end

    it 'returns self for chaining' do
      expect(attractor.erode!).to eq(attractor)
    end
  end

  describe '#pull_strength_at' do
    it 'returns positive pull for distance within pull_radius' do
      strength = attractor.pull_strength_at(distance: 0.5)
      expect(strength).to be > 0
    end

    it 'returns zero for distance beyond pull_radius' do
      strength = attractor.pull_strength_at(distance: 2.0)
      expect(strength).to eq(0.0)
    end

    it 'returns zero for zero distance' do
      strength = attractor.pull_strength_at(distance: 0)
      expect(strength).to eq(0.0)
    end

    it 'returns stronger pull for heavier attractors' do
      heavy = described_class.new(content: 'heavy', mass: 3.0)
      light = described_class.new(content: 'light', mass: 0.5)
      expect(heavy.pull_strength_at(distance: 0.5)).to be > light.pull_strength_at(distance: 0.5)
    end

    it 'returns stronger pull for closer distance' do
      close_pull = attractor.pull_strength_at(distance: 0.3)
      far_pull   = attractor.pull_strength_at(distance: 0.8)
      expect(close_pull).to be > far_pull
    end
  end

  describe '#collapsed?' do
    it 'returns false for normal mass' do
      expect(attractor.collapsed?).to be false
    end

    it 'returns true when mass is below collapse threshold' do
      a = described_class.new(content: 'x', mass: 0.05)
      expect(a.collapsed?).to be true
    end
  end

  describe '#supermassive?' do
    it 'returns false for normal mass' do
      expect(attractor.supermassive?).to be false
    end

    it 'returns true for mass at or above supermassive threshold' do
      a = described_class.new(content: 'x', mass: 3.0)
      expect(a.supermassive?).to be true
    end
  end

  describe '#mass_label' do
    it 'returns a symbol label' do
      expect(attractor.mass_label).to be_a(Symbol)
    end

    it 'returns :nascent for default mass' do
      expect(attractor.mass_label).to eq(:nascent)
    end
  end

  describe '#to_h' do
    it 'returns a hash with expected keys' do
      h = attractor.to_h
      expect(h).to include(:id, :content, :domain, :mass, :pull_radius, :decay_rate,
                           :reinforcement_count, :collapsed, :supermassive, :mass_label, :created_at)
    end
  end
end

# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Gravity::Helpers::OrbitingThought do
  let(:attractor_id) { 'test-attractor-uuid' }

  subject(:thought) do
    described_class.new(content: 'orbiting idea', attractor_id: attractor_id, orbital_distance: 0.8)
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(thought.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets content' do
      expect(thought.content).to eq('orbiting idea')
    end

    it 'sets attractor_id' do
      expect(thought.attractor_id).to eq(attractor_id)
    end

    it 'sets orbital_distance' do
      expect(thought.orbital_distance).to eq(0.8)
    end

    it 'sets velocity' do
      expect(thought.velocity).to eq(0.0)
    end

    it 'sets created_at' do
      expect(thought.created_at).to be_a(Time)
    end
  end

  describe '#approach!' do
    it 'decreases orbital distance' do
      thought.approach!(0.2)
      expect(thought.orbital_distance).to be_within(0.001).of(0.6)
    end

    it 'does not go below zero' do
      t = described_class.new(content: 'x', attractor_id: attractor_id, orbital_distance: 0.05)
      t.approach!(1.0)
      expect(t.orbital_distance).to eq(0.0)
    end

    it 'returns self for chaining' do
      expect(thought.approach!(0.1)).to eq(thought)
    end
  end

  describe '#escape!' do
    it 'increases orbital distance' do
      thought.escape!(0.3)
      expect(thought.orbital_distance).to be_within(0.001).of(1.1)
    end

    it 'returns self for chaining' do
      expect(thought.escape!(0.1)).to eq(thought)
    end
  end

  describe '#captured?' do
    it 'returns false for normal orbital distance' do
      expect(thought.captured?).to be false
    end

    it 'returns true when distance is below capture radius' do
      t = described_class.new(content: 'x', attractor_id: attractor_id, orbital_distance: 0.1)
      expect(t.captured?).to be true
    end
  end

  describe '#escaped?' do
    it 'returns false for normal orbital distance' do
      expect(thought.escaped?).to be false
    end

    it 'returns true when distance is above escape radius' do
      t = described_class.new(content: 'x', attractor_id: attractor_id, orbital_distance: 2.0)
      expect(t.escaped?).to be true
    end
  end

  describe '#orbit_label' do
    it 'returns a symbol' do
      expect(thought.orbit_label).to be_a(Symbol)
    end

    it 'returns :stable for distance 0.8' do
      expect(thought.orbit_label).to eq(:stable)
    end
  end

  describe '#to_h' do
    it 'returns a hash with expected keys' do
      h = thought.to_h
      expect(h).to include(:id, :content, :attractor_id, :orbital_distance, :velocity,
                           :captured, :escaped, :orbit_label, :created_at)
    end
  end
end

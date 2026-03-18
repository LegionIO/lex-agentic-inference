# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Momentum::Helpers::Idea do
  subject(:idea) { described_class.new(content: 'test idea', idea_type: :belief, domain: :general) }

  describe '#initialize' do
    it 'creates an idea with defaults' do
      expect(idea.content).to eq('test idea')
      expect(idea.idea_type).to eq(:belief)
      expect(idea.domain).to eq(:general)
      expect(idea.mass).to eq(0.5)
      expect(idea.velocity).to eq(0.0)
      expect(idea.reinforcement_count).to eq(0)
      expect(idea.challenge_count).to eq(0)
    end

    it 'generates a uuid' do
      expect(idea.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'clamps mass to valid range' do
      heavy = described_class.new(content: 'x', idea_type: :goal, domain: :d, mass: 5.0)
      expect(heavy.mass).to eq(1.0)
    end
  end

  describe '#momentum' do
    it 'returns mass * velocity' do
      expect(idea.momentum).to eq(0.0)
    end

    it 'reflects velocity after reinforcement' do
      idea.reinforce!
      expect(idea.momentum).to be > 0
    end
  end

  describe '#reinforce!' do
    it 'increases mass and velocity' do
      old_mass = idea.mass
      old_velocity = idea.velocity
      idea.reinforce!
      expect(idea.mass).to be > old_mass
      expect(idea.velocity).to be > old_velocity
      expect(idea.reinforcement_count).to eq(1)
    end

    it 'clamps velocity to ceiling' do
      20.times { idea.reinforce! }
      expect(idea.velocity).to be <= 1.0
    end
  end

  describe '#challenge!' do
    it 'reduces velocity and slightly reduces mass' do
      idea.reinforce!
      idea.reinforce!
      old_velocity = idea.velocity
      old_mass = idea.mass
      idea.challenge!
      expect(idea.velocity).to be < old_velocity
      expect(idea.mass).to be < old_mass
      expect(idea.challenge_count).to eq(1)
    end
  end

  describe '#apply_force' do
    it 'accelerates inversely proportional to mass' do
      idea.apply_force(force: 0.1)
      expected_accel = 0.1 / 0.5
      expect(idea.velocity).to be_within(0.001).of(expected_accel)
    end

    it 'heavier ideas accelerate less' do
      heavy = described_class.new(content: 'x', idea_type: :belief, domain: :d, mass: 1.0)
      light = described_class.new(content: 'x', idea_type: :belief, domain: :d, mass: 0.2)
      heavy.apply_force(force: 0.1)
      light.apply_force(force: 0.1)
      expect(light.velocity).to be > heavy.velocity
    end
  end

  describe '#apply_friction!' do
    it 'reduces positive velocity toward zero' do
      idea.reinforce!
      old_velocity = idea.velocity
      idea.apply_friction!
      expect(idea.velocity).to be < old_velocity
      expect(idea.velocity).to be >= 0.0
    end

    it 'reduces negative velocity toward zero' do
      idea.challenge!
      idea.challenge!
      old_velocity = idea.velocity
      idea.apply_friction!
      expect(idea.velocity).to be > old_velocity
      expect(idea.velocity).to be <= 0.0
    end

    it 'does nothing when velocity is zero' do
      idea.apply_friction!
      expect(idea.velocity).to eq(0.0)
    end
  end

  describe '#momentum_label' do
    it 'returns a symbol' do
      expect(idea.momentum_label).to be_a(Symbol)
    end

    it 'returns :surging for high momentum' do
      10.times { idea.reinforce! }
      expect(idea.momentum_label).to eq(:surging)
    end
  end

  describe '#inertia_label' do
    it 'returns :moderate for default mass' do
      expect(idea.inertia_label).to eq(:moderate)
    end

    it 'returns :immovable for high mass' do
      heavy = described_class.new(content: 'x', idea_type: :belief, domain: :d, mass: 0.9)
      expect(heavy.inertia_label).to eq(:immovable)
    end
  end

  describe 'predicate methods' do
    it '#at_rest? is true when velocity near zero' do
      expect(idea.at_rest?).to be true
    end

    it '#surging? is true with high momentum' do
      10.times { idea.reinforce! }
      expect(idea.surging?).to be true
    end

    it '#entrenched? is true with high mass' do
      10.times { idea.reinforce! }
      expect(idea.entrenched?).to be true
    end
  end

  describe '#to_h' do
    it 'returns a complete hash' do
      hash = idea.to_h
      expect(hash).to include(:id, :content, :idea_type, :domain, :mass, :velocity,
                              :momentum, :momentum_label, :inertia_label)
    end
  end
end

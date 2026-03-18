# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Intuition::Helpers::Pattern do
  subject(:pattern) do
    described_class.new(
      id:       :pat_one,
      cue:      { color: :red, shape: :circle },
      response: :stop,
      domain:   :traffic
    )
  end

  describe '#initialize' do
    it 'sets attributes' do
      expect(pattern.cue).to eq({ color: :red, shape: :circle })
      expect(pattern.response).to eq(:stop)
      expect(pattern.domain).to eq(:traffic)
      expect(pattern.encounters).to eq(0)
      expect(pattern.state).to eq(:developing)
    end

    it 'clamps strength' do
      p = described_class.new(id: :x, cue: {}, response: :y, strength: 2.0)
      expect(p.strength).to eq(0.95)
    end
  end

  describe '#match_score' do
    it 'returns 1.0 for exact match' do
      score = pattern.match_score({ color: :red, shape: :circle })
      expect(score).to eq(1.0)
    end

    it 'returns partial score for partial match' do
      score = pattern.match_score({ color: :red, shape: :square })
      expect(score).to eq(0.5)
    end

    it 'returns 0.0 for no match' do
      score = pattern.match_score({ color: :blue, shape: :square })
      expect(score).to eq(0.0)
    end

    it 'returns 0.0 for non-hash input' do
      expect(pattern.match_score('not a hash')).to eq(0.0)
    end

    it 'handles disjoint keys' do
      score = pattern.match_score({ size: :large, weight: :heavy })
      expect(score).to eq(0.0)
    end
  end

  describe '#recognized?' do
    it 'returns true for high match' do
      expect(pattern.recognized?({ color: :red, shape: :circle })).to be true
    end

    it 'returns false for low match' do
      expect(pattern.recognized?({ color: :blue, shape: :square })).to be false
    end
  end

  describe '#reinforce' do
    it 'increases strength on success' do
      original = pattern.strength
      pattern.reinforce(success: true)
      expect(pattern.strength).to be > original
      expect(pattern.encounters).to eq(1)
      expect(pattern.successes).to eq(1)
    end

    it 'decreases strength on failure' do
      original = pattern.strength
      pattern.reinforce(success: false)
      expect(pattern.strength).to be < original
      expect(pattern.encounters).to eq(1)
      expect(pattern.successes).to eq(0)
    end

    it 'clamps to ceiling' do
      p = described_class.new(id: :x, cue: {}, response: :y, strength: 0.92)
      p.reinforce(success: true)
      expect(p.strength).to be <= 0.95
    end
  end

  describe '#decay' do
    it 'reduces strength' do
      original = pattern.strength
      pattern.decay
      expect(pattern.strength).to be < original
    end

    it 'does not go below floor' do
      p = described_class.new(id: :x, cue: {}, response: :y, strength: 0.06)
      p.decay
      expect(p.strength).to be >= 0.05
    end
  end

  describe '#success_rate' do
    it 'returns 0.0 with no encounters' do
      expect(pattern.success_rate).to eq(0.0)
    end

    it 'calculates correctly' do
      pattern.reinforce(success: true)
      pattern.reinforce(success: false)
      expect(pattern.success_rate).to eq(0.5)
    end
  end

  describe '#reliable? and #expert?' do
    it 'starts as not reliable' do
      expect(pattern.reliable?).to be false
    end

    it 'becomes reliable with enough encounters and strength' do
      p = described_class.new(id: :x, cue: {}, response: :y, strength: 0.7)
      3.times { p.reinforce(success: true) }
      expect(p.reliable?).to be true
    end

    it 'becomes expert with many encounters and high strength' do
      p = described_class.new(id: :x, cue: {}, response: :y, strength: 0.85)
      10.times { p.reinforce(success: true) }
      expect(p.expert?).to be true
    end
  end

  describe '#state transitions' do
    it 'starts as developing at default strength' do
      expect(pattern.state).to eq(:developing)
    end

    it 'transitions through states with reinforcement' do
      p = described_class.new(id: :x, cue: {}, response: :y, strength: 0.3)
      expect(p.state).to eq(:nascent)
      4.times { p.reinforce(success: true) }
      expect(%i[developing reliable]).to include(p.state)
    end
  end

  describe '#confidence_label' do
    it 'returns a symbol' do
      expect(pattern.confidence_label).to be_a(Symbol)
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      expect(pattern.to_h).to include(
        :id, :cue, :response, :domain, :strength,
        :encounters, :successes, :success_rate, :state,
        :confidence_label, :reliable, :expert
      )
    end
  end
end

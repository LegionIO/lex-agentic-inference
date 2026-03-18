# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Intuition::Helpers::Heuristic do
  subject(:heuristic) do
    described_class.new(
      id:             :heur_one,
      name:           'take the best',
      heuristic_type: :take_the_best,
      domain:         :decision
    )
  end

  describe '#initialize' do
    it 'sets attributes' do
      expect(heuristic.name).to eq('take the best')
      expect(heuristic.heuristic_type).to eq(:take_the_best)
      expect(heuristic.domain).to eq(:decision)
      expect(heuristic.uses).to eq(0)
      expect(heuristic.successes).to eq(0)
    end

    it 'defaults invalid type to :fast_and_frugal' do
      h = described_class.new(id: :x, name: 'test', heuristic_type: :bogus)
      expect(h.heuristic_type).to eq(:fast_and_frugal)
    end
  end

  describe '#apply' do
    it 'increments uses' do
      heuristic.apply
      expect(heuristic.uses).to eq(1)
    end
  end

  describe '#record_outcome' do
    it 'increments successes on success' do
      heuristic.record_outcome(success: true)
      expect(heuristic.successes).to eq(1)
    end

    it 'does not increment on failure' do
      heuristic.record_outcome(success: false)
      expect(heuristic.successes).to eq(0)
    end
  end

  describe '#success_rate' do
    it 'returns 0.0 with no uses' do
      expect(heuristic.success_rate).to eq(0.0)
    end

    it 'calculates correctly' do
      3.times { heuristic.apply }
      2.times { heuristic.record_outcome(success: true) }
      heuristic.record_outcome(success: false)
      expect(heuristic.success_rate).to be_within(0.01).of(0.67)
    end
  end

  describe '#effective?' do
    it 'returns false with few uses' do
      expect(heuristic.effective?).to be false
    end

    it 'returns true with enough successful uses' do
      4.times do
        heuristic.apply
        heuristic.record_outcome(success: true)
      end
      expect(heuristic.effective?).to be true
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      expect(heuristic.to_h).to include(
        :id, :name, :heuristic_type, :domain,
        :uses, :successes, :success_rate, :effective
      )
    end
  end
end

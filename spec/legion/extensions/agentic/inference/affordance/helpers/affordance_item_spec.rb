# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Affordance::Helpers::AffordanceItem do
  subject(:item) do
    described_class.new(id: :aff_one, action: :send_message, domain: :communication,
                        affordance_type: :action_possible)
  end

  let(:constants) { Legion::Extensions::Agentic::Inference::Affordance::Helpers::Constants }

  describe '#initialize' do
    it 'sets id, action, domain, and type' do
      expect(item.id).to eq(:aff_one)
      expect(item.action).to eq(:send_message)
      expect(item.domain).to eq(:communication)
      expect(item.affordance_type).to eq(:action_possible)
    end

    it 'defaults relevance' do
      expect(item.relevance).to eq(constants::DEFAULT_RELEVANCE)
    end
  end

  describe '#actionable?' do
    it 'returns true for possible action above threshold' do
      expect(item.actionable?).to be true
    end

    it 'returns false for blocked actions' do
      blocked = described_class.new(id: :x, action: :y, domain: :d, affordance_type: :action_blocked)
      expect(blocked.actionable?).to be false
    end

    it 'returns false when below threshold' do
      item.relevance = 0.2
      expect(item.actionable?).to be false
    end
  end

  describe '#blocked?' do
    it 'returns true for blocked type' do
      b = described_class.new(id: :x, action: :y, domain: :d, affordance_type: :action_blocked)
      expect(b.blocked?).to be true
    end

    it 'returns false otherwise' do
      expect(item.blocked?).to be false
    end
  end

  describe '#risky?' do
    it 'returns true for risky type' do
      r = described_class.new(id: :x, action: :y, domain: :d, affordance_type: :action_risky)
      expect(r.risky?).to be true
    end
  end

  describe '#threatening?' do
    it 'returns true for threat type' do
      t = described_class.new(id: :x, action: :y, domain: :d, affordance_type: :threat)
      expect(t.threatening?).to be true
    end
  end

  describe '#decay' do
    it 'reduces relevance' do
      before = item.relevance
      item.decay
      expect(item.relevance).to be < before
    end

    it 'does not go below zero' do
      100.times { item.decay }
      expect(item.relevance).to be >= 0.0
    end
  end

  describe '#faded?' do
    it 'returns false initially' do
      expect(item.faded?).to be false
    end

    it 'returns true at floor' do
      item.relevance = constants::RELEVANCE_FLOOR
      expect(item.faded?).to be true
    end
  end

  describe '#relevance_label' do
    it 'returns :moderate for default relevance' do
      expect(item.relevance_label).to eq(:moderate)
    end

    it 'returns :critical for high relevance' do
      item.relevance = 0.9
      expect(item.relevance_label).to eq(:critical)
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      h = item.to_h
      expect(h).to include(:id, :action, :domain, :affordance_type, :requires,
                           :relevance, :relevance_label, :actionable, :blocked, :risky)
    end
  end
end

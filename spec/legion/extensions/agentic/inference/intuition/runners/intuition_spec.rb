# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Intuition::Runners::Intuition do
  let(:host) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  let(:cue) { { color: :red, shape: :circle } }

  describe '#learn_intuitive_pattern' do
    it 'creates a pattern' do
      result = host.learn_intuitive_pattern(cue: cue, response: :stop)
      expect(result[:success]).to be true
      expect(result[:pattern_id]).to be_a(Symbol)
    end
  end

  describe '#intuitive_recognize' do
    it 'recognizes patterns' do
      host.learn_intuitive_pattern(cue: cue, response: :stop)
      result = host.intuitive_recognize(input_cue: cue)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#intuit_response' do
    it 'returns the intuited response' do
      host.learn_intuitive_pattern(cue: cue, response: :stop, strength: 0.8)
      result = host.intuit_response(input_cue: cue)
      expect(result[:success]).to be true
      expect(result[:response]).to eq(:stop)
    end

    it 'returns failure for no match' do
      result = host.intuit_response(input_cue: { unknown: :thing })
      expect(result[:success]).to be false
    end
  end

  describe '#reinforce_intuition' do
    it 'reinforces a pattern' do
      created = host.learn_intuitive_pattern(cue: cue, response: :stop)
      result = host.reinforce_intuition(pattern_id: created[:pattern_id], success: true)
      expect(result[:success]).to be true
    end

    it 'returns failure for unknown pattern' do
      result = host.reinforce_intuition(pattern_id: :bogus, success: true)
      expect(result[:success]).to be false
    end
  end

  describe '#add_intuitive_heuristic' do
    it 'creates a heuristic' do
      result = host.add_intuitive_heuristic(name: 'test', heuristic_type: :recognition)
      expect(result[:success]).to be true
      expect(result[:heuristic_id]).to be_a(Symbol)
    end
  end

  describe '#apply_intuitive_heuristic' do
    it 'applies a heuristic' do
      created = host.add_intuitive_heuristic(name: 'test', heuristic_type: :satisficing)
      result = host.apply_intuitive_heuristic(heuristic_id: created[:heuristic_id])
      expect(result[:success]).to be true
    end

    it 'returns failure for unknown heuristic' do
      result = host.apply_intuitive_heuristic(heuristic_id: :bogus)
      expect(result[:success]).to be false
    end
  end

  describe '#reliable_intuitions' do
    it 'returns reliable patterns' do
      result = host.reliable_intuitions
      expect(result[:success]).to be true
      expect(result[:count]).to eq(0)
    end
  end

  describe '#expert_intuitions' do
    it 'returns expert patterns' do
      result = host.expert_intuitions
      expect(result[:success]).to be true
    end
  end

  describe '#update_intuition' do
    it 'decays and returns stats' do
      result = host.update_intuition
      expect(result[:success]).to be true
    end
  end

  describe '#intuition_stats' do
    it 'returns stats' do
      result = host.intuition_stats
      expect(result[:success]).to be true
      expect(result).to have_key(:pattern_count)
      expect(result).to have_key(:heuristic_count)
    end
  end
end

# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Intuition::Helpers::IntuitionEngine do
  subject(:eng) { described_class.new }

  let(:cue) { { color: :red, shape: :circle } }

  describe '#learn_pattern' do
    it 'creates a pattern' do
      pattern = eng.learn_pattern(cue: cue, response: :stop)
      expect(pattern).to be_a(Legion::Extensions::Agentic::Inference::Intuition::Helpers::Pattern)
      expect(eng.patterns.size).to eq(1)
    end

    it 'enforces MAX_PATTERNS' do
      200.times { |i| eng.learn_pattern(cue: { n: i }, response: :x) }
      expect(eng.learn_pattern(cue: { n: :overflow }, response: :x)).to be_nil
    end

    it 'records event' do
      eng.learn_pattern(cue: cue, response: :stop)
      expect(eng.history.size).to eq(1)
    end
  end

  describe '#recognize' do
    it 'finds matching patterns' do
      eng.learn_pattern(cue: cue, response: :stop, domain: :traffic)
      matches = eng.recognize(input_cue: { color: :red, shape: :circle })
      expect(matches.size).to eq(1)
    end

    it 'filters by domain' do
      eng.learn_pattern(cue: cue, response: :stop, domain: :traffic)
      eng.learn_pattern(cue: cue, response: :danger, domain: :safety)
      matches = eng.recognize(input_cue: cue, domain: :traffic)
      expect(matches.size).to eq(1)
    end

    it 'returns empty for no match' do
      eng.learn_pattern(cue: { x: 1 }, response: :y)
      matches = eng.recognize(input_cue: { a: 2, b: 3 })
      expect(matches).to be_empty
    end

    it 'sorts by match score descending' do
      eng.learn_pattern(cue: { color: :red }, response: :partial)
      eng.learn_pattern(cue: { color: :red, shape: :circle }, response: :exact)
      matches = eng.recognize(input_cue: cue)
      expect(matches.first[:score]).to be >= matches.last[:score]
    end
  end

  describe '#intuit' do
    it 'returns best matching response' do
      eng.learn_pattern(cue: cue, response: :stop, strength: 0.8)
      result = eng.intuit(input_cue: cue)
      expect(result[:response]).to eq(:stop)
      expect(result[:confidence]).to eq(0.8)
      expect(result).to have_key(:mode)
    end

    it 'returns nil when no match' do
      result = eng.intuit(input_cue: { unknown: :thing })
      expect(result).to be_nil
    end

    it 'returns :compiled_expertise mode for expert patterns' do
      p = eng.learn_pattern(cue: cue, response: :stop, strength: 0.85)
      10.times { p.reinforce(success: true) }
      result = eng.intuit(input_cue: cue)
      expect(result[:mode]).to eq(:compiled_expertise)
    end
  end

  describe '#reinforce_pattern' do
    it 'reinforces on success' do
      pattern = eng.learn_pattern(cue: cue, response: :stop)
      original = pattern.strength
      eng.reinforce_pattern(pattern_id: pattern.id, success: true)
      expect(pattern.strength).to be > original
    end

    it 'returns nil for unknown pattern' do
      expect(eng.reinforce_pattern(pattern_id: :bogus, success: true)).to be_nil
    end
  end

  describe '#add_heuristic' do
    it 'creates a heuristic' do
      h = eng.add_heuristic(name: 'recognition', heuristic_type: :recognition)
      expect(h).to be_a(Legion::Extensions::Agentic::Inference::Intuition::Helpers::Heuristic)
    end

    it 'enforces MAX_HEURISTICS' do
      50.times { |i| eng.add_heuristic(name: "h_#{i}", heuristic_type: :recognition) }
      expect(eng.add_heuristic(name: 'overflow', heuristic_type: :recognition)).to be_nil
    end
  end

  describe '#apply_heuristic' do
    it 'applies and returns hash' do
      h = eng.add_heuristic(name: 'test', heuristic_type: :satisficing)
      result = eng.apply_heuristic(heuristic_id: h.id)
      expect(result[:uses]).to eq(1)
    end

    it 'returns nil for unknown heuristic' do
      expect(eng.apply_heuristic(heuristic_id: :bogus)).to be_nil
    end
  end

  describe '#reliable_patterns and #expert_patterns' do
    it 'returns reliable patterns' do
      p = eng.learn_pattern(cue: cue, response: :stop, strength: 0.7)
      3.times { p.reinforce(success: true) }
      expect(eng.reliable_patterns.size).to eq(1)
    end

    it 'returns expert patterns' do
      p = eng.learn_pattern(cue: cue, response: :stop, strength: 0.85)
      10.times { p.reinforce(success: true) }
      expect(eng.expert_patterns.size).to eq(1)
    end
  end

  describe '#effective_heuristics' do
    it 'returns effective heuristics' do
      h = eng.add_heuristic(name: 'test', heuristic_type: :recognition)
      4.times do
        h.apply
        h.record_outcome(success: true)
      end
      expect(eng.effective_heuristics.size).to eq(1)
    end
  end

  describe '#patterns_in' do
    it 'filters by domain' do
      eng.learn_pattern(cue: { x: 1 }, response: :a, domain: :traffic)
      eng.learn_pattern(cue: { y: 2 }, response: :b, domain: :safety)
      expect(eng.patterns_in(domain: :traffic).size).to eq(1)
    end
  end

  describe '#decay_all' do
    it 'decays all patterns' do
      p = eng.learn_pattern(cue: cue, response: :stop, strength: 0.8)
      original = p.strength
      eng.decay_all
      expect(p.strength).to be < original
    end
  end

  describe '#to_h' do
    it 'returns expected keys' do
      expect(eng.to_h).to include(
        :pattern_count, :heuristic_count, :reliable_pattern_count,
        :expert_pattern_count, :effective_heuristic_count, :history_size
      )
    end
  end
end

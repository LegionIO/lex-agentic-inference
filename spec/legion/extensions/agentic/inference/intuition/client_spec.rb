# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Intuition::Client do
  subject(:client) { described_class.new }

  it 'includes the Intuition runner' do
    expect(client).to respond_to(:intuit_response)
  end

  it 'accepts an injected engine' do
    engine = Legion::Extensions::Agentic::Inference::Intuition::Helpers::IntuitionEngine.new
    c = described_class.new(engine: engine)
    expect(c.intuition_stats[:success]).to be true
  end

  it 'supports full learn-recognize-reinforce cycle' do
    cue = { weather: :sunny, wind: :low }
    created = client.learn_intuitive_pattern(cue: cue, response: :go_outside, strength: 0.6)
    expect(created[:success]).to be true

    result = client.intuit_response(input_cue: cue)
    expect(result[:response]).to eq(:go_outside)

    reinforced = client.reinforce_intuition(pattern_id: created[:pattern_id], success: true)
    expect(reinforced[:strength]).to be > 0.6
  end

  it 'supports heuristic lifecycle' do
    created = client.add_intuitive_heuristic(name: 'quick scan', heuristic_type: :recognition)
    applied = client.apply_intuitive_heuristic(heuristic_id: created[:heuristic_id])
    expect(applied[:uses]).to eq(1)
  end
end

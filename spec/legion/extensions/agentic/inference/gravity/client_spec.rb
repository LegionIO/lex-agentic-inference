# frozen_string_literal: true

require 'legion/extensions/agentic/inference/gravity/client'

RSpec.describe Legion::Extensions::Agentic::Inference::Gravity::Client do
  it 'responds to all runner methods' do
    client = described_class.new
    expect(client).to respond_to(:create_attractor)
    expect(client).to respond_to(:add_thought)
    expect(client).to respond_to(:tick_gravity)
    expect(client).to respond_to(:accrete)
    expect(client).to respond_to(:erode)
    expect(client).to respond_to(:strongest_attractors)
    expect(client).to respond_to(:thought_distribution)
    expect(client).to respond_to(:cognitive_density_map)
    expect(client).to respond_to(:gravity_report)
  end

  it 'initializes with a fresh gravity engine' do
    client = described_class.new
    result = client.gravity_report
    expect(result[:report][:total_attractors]).to eq(0)
  end
end

# frozen_string_literal: true

require 'legion/extensions/agentic/inference/affordance/client'

RSpec.describe Legion::Extensions::Agentic::Inference::Affordance::Client do
  subject(:client) { described_class.new }

  it 'detects and evaluates affordances' do
    client.register_capability(name: :http_client)
    client.detect_affordance(action: :send, domain: :comm, affordance_type: :action_possible,
                             requires: [:http_client])
    result = client.evaluate_action(action: :send, domain: :comm)
    expect(result[:feasible]).to be true
  end

  it 'detects threats' do
    client.detect_affordance(action: :intrusion, domain: :security, affordance_type: :threat, relevance: 0.9)
    result = client.current_threats
    expect(result[:count]).to eq(1)
  end

  it 'reports stats' do
    result = client.affordance_stats
    expect(result[:success]).to be true
  end
end

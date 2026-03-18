# frozen_string_literal: true

require 'legion/extensions/agentic/inference/abductive/client'

RSpec.describe Legion::Extensions::Agentic::Inference::Abductive::Client do
  it 'responds to all runner methods' do
    client = described_class.new
    expect(client).to respond_to(:record_observation)
    expect(client).to respond_to(:generate_hypothesis)
    expect(client).to respond_to(:evaluate_hypothesis)
    expect(client).to respond_to(:add_hypothesis_evidence)
    expect(client).to respond_to(:best_explanation)
    expect(client).to respond_to(:competing_hypotheses)
    expect(client).to respond_to(:refute_hypothesis)
    expect(client).to respond_to(:unexplained_observations)
    expect(client).to respond_to(:update_abductive_reasoning)
    expect(client).to respond_to(:abductive_reasoning_stats)
  end

  it 'accepts a custom engine' do
    custom_engine = Legion::Extensions::Agentic::Inference::Abductive::Helpers::AbductionEngine.new
    client = described_class.new(engine: custom_engine)
    expect(client).to be_a(described_class)
  end
end

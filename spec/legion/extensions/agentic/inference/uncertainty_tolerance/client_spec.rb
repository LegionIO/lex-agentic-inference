# frozen_string_literal: true

require 'legion/extensions/agentic/inference/uncertainty_tolerance/client'

RSpec.describe Legion::Extensions::Agentic::Inference::UncertaintyTolerance::Client do
  let(:client) { described_class.new }

  it 'responds to all runner methods' do
    expect(client).to respond_to(:record_uncertain_decision)
    expect(client).to respond_to(:resolve_uncertain_decision)
    expect(client).to respond_to(:should_act_assessment)
    expect(client).to respond_to(:uncertainty_profile)
    expect(client).to respond_to(:decisions_under_uncertainty_report)
    expect(client).to respond_to(:domain_tolerance_report)
    expect(client).to respond_to(:update_uncertainty_tolerance)
    expect(client).to respond_to(:uncertainty_tolerance_stats)
  end
end

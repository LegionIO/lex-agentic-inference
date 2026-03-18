# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::ExpectationViolation do
  it 'has a version number' do
    expect(Legion::Extensions::Agentic::Inference::ExpectationViolation::VERSION).not_to be_nil
  end

  it 'has a version that is a string' do
    expect(Legion::Extensions::Agentic::Inference::ExpectationViolation::VERSION).to be_a(String)
  end
end

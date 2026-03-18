# frozen_string_literal: true

require 'legion/extensions/agentic/inference/affordance/runners/affordance'

RSpec.describe Legion::Extensions::Agentic::Inference::Affordance::Runners::Affordance do
  let(:aff_field) { Legion::Extensions::Agentic::Inference::Affordance::Helpers::AffordanceField.new }
  let(:host) do
    obj = Object.new
    obj.extend(described_class)
    obj.instance_variable_set(:@field, aff_field)
    obj
  end

  describe '#register_capability' do
    it 'registers successfully' do
      result = host.register_capability(name: :http_client)
      expect(result[:success]).to be true
    end
  end

  describe '#set_environment' do
    it 'sets property' do
      result = host.set_environment(property: :status, value: :online)
      expect(result[:success]).to be true
    end
  end

  describe '#detect_affordance' do
    it 'detects an affordance' do
      result = host.detect_affordance(action: :send, domain: :comm, affordance_type: :action_possible)
      expect(result[:success]).to be true
      expect(result[:affordance][:action]).to eq(:send)
    end

    it 'fails for invalid type' do
      result = host.detect_affordance(action: :x, domain: :d, affordance_type: :bogus)
      expect(result[:success]).to be false
    end
  end

  describe '#evaluate_action' do
    it 'evaluates feasibility' do
      host.detect_affordance(action: :send, domain: :comm, affordance_type: :action_possible)
      result = host.evaluate_action(action: :send, domain: :comm)
      expect(result[:success]).to be true
      expect(result[:feasible]).to be true
    end
  end

  describe '#actionable_affordances' do
    it 'returns actionable items' do
      result = host.actionable_affordances
      expect(result[:success]).to be true
    end
  end

  describe '#current_threats' do
    it 'returns threats' do
      result = host.current_threats
      expect(result[:success]).to be true
    end
  end

  describe '#update_affordances' do
    it 'decays' do
      result = host.update_affordances
      expect(result[:success]).to be true
    end
  end

  describe '#affordance_stats' do
    it 'returns stats' do
      result = host.affordance_stats
      expect(result[:success]).to be true
      expect(result[:stats]).to include(:affordance_count)
    end
  end
end

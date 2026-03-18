# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Affordance::Helpers::AffordanceField do
  subject(:field) { described_class.new }

  let(:constants) { Legion::Extensions::Agentic::Inference::Affordance::Helpers::Constants }

  describe '#register_capability' do
    it 'adds a capability' do
      result = field.register_capability(name: :http_client, domain: :network)
      expect(result).to be_a(Hash)
      expect(field.capabilities.size).to eq(1)
    end

    it 'enforces limit' do
      constants::MAX_CAPABILITIES.times { |i| field.register_capability(name: :"cap_#{i}") }
      expect(field.register_capability(name: :overflow)).to be_nil
    end
  end

  describe '#set_environment' do
    it 'sets a property' do
      result = field.set_environment(property: :network_status, value: :online)
      expect(result).to be_a(Hash)
      expect(field.environment.size).to eq(1)
    end

    it 'updates existing property' do
      field.set_environment(property: :status, value: :offline)
      field.set_environment(property: :status, value: :online)
      expect(field.environment[:status][:value]).to eq(:online)
    end
  end

  describe '#detect_affordance' do
    it 'creates an affordance' do
      aff = field.detect_affordance(action: :send, domain: :comm, affordance_type: :action_possible)
      expect(aff).to be_a(Legion::Extensions::Agentic::Inference::Affordance::Helpers::AffordanceItem)
      expect(field.affordances.size).to eq(1)
    end

    it 'rejects invalid types' do
      expect(field.detect_affordance(action: :x, domain: :d, affordance_type: :bogus)).to be_nil
    end

    it 'enforces MAX_AFFORDANCES' do
      constants::MAX_AFFORDANCES.times do |i|
        field.detect_affordance(action: :"a_#{i}", domain: :d, affordance_type: :neutral)
      end
      expect(field.detect_affordance(action: :overflow, domain: :d, affordance_type: :neutral)).to be_nil
    end
  end

  describe '#evaluate_action' do
    it 'returns not feasible when no affordance exists' do
      result = field.evaluate_action(action: :fly, domain: :motion)
      expect(result[:feasible]).to be false
      expect(result[:reason]).to eq(:no_affordance)
    end

    it 'returns blocked when blocker exists' do
      field.detect_affordance(action: :send, domain: :comm, affordance_type: :action_blocked)
      result = field.evaluate_action(action: :send, domain: :comm)
      expect(result[:feasible]).to be false
      expect(result[:reason]).to eq(:blocked)
    end

    it 'returns feasible when capable and not blocked' do
      field.register_capability(name: :http_client)
      field.detect_affordance(action: :send, domain: :comm, affordance_type: :action_possible,
                              requires: [:http_client])
      result = field.evaluate_action(action: :send, domain: :comm)
      expect(result[:feasible]).to be true
    end

    it 'returns not feasible when capabilities missing' do
      field.detect_affordance(action: :send, domain: :comm, affordance_type: :action_possible,
                              requires: [:missing_cap])
      result = field.evaluate_action(action: :send, domain: :comm)
      expect(result[:feasible]).to be false
      expect(result[:reason]).to eq(:missing_capabilities)
    end

    it 'includes risks' do
      field.detect_affordance(action: :send, domain: :comm, affordance_type: :action_risky)
      result = field.evaluate_action(action: :send, domain: :comm)
      expect(result[:risks]).not_to be_empty
    end
  end

  describe '#actionable_affordances' do
    it 'returns only actionable items sorted by relevance' do
      field.detect_affordance(action: :send, domain: :comm, affordance_type: :action_possible, relevance: 0.8)
      field.detect_affordance(action: :block, domain: :comm, affordance_type: :action_blocked)
      items = field.actionable_affordances
      expect(items.size).to eq(1)
      expect(items.first[:action]).to eq(:send)
    end
  end

  describe '#threats' do
    it 'returns threat affordances' do
      field.detect_affordance(action: :attack, domain: :security, affordance_type: :threat)
      expect(field.threats.size).to eq(1)
    end
  end

  describe '#affordances_in' do
    it 'filters by domain' do
      field.detect_affordance(action: :send, domain: :comm, affordance_type: :action_possible)
      field.detect_affordance(action: :read, domain: :data, affordance_type: :resource_available)
      expect(field.affordances_in(domain: :comm).size).to eq(1)
    end
  end

  describe '#decay_all' do
    it 'decays and removes faded affordances' do
      field.detect_affordance(action: :faint, domain: :d, affordance_type: :neutral, relevance: 0.06)
      10.times { field.decay_all }
      expect(field.affordances).to be_empty
    end
  end

  describe '#to_h' do
    it 'returns summary hash' do
      h = field.to_h
      expect(h).to include(:affordance_count, :capability_count, :environment_props,
                           :actionable_count, :blocked_count, :threat_count, :history_size)
    end
  end
end

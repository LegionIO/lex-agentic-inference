# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Inference::Schema::Client do
  describe '#initialize' do
    it 'creates a default world model' do
      client = described_class.new
      expect(client.world_model).to be_a(Legion::Extensions::Agentic::Inference::Schema::Helpers::WorldModel)
    end

    it 'accepts an injected world model' do
      wm = Legion::Extensions::Agentic::Inference::Schema::Helpers::WorldModel.new
      client = described_class.new(world_model: wm)
      expect(client.world_model).to equal(wm)
    end

    it 'ignores unknown keyword arguments' do
      expect { described_class.new(unknown: true) }.not_to raise_error
    end
  end

  describe 'runner integration' do
    subject(:client) { described_class.new }

    it 'responds to learn_relation' do
      expect(client).to respond_to(:learn_relation)
    end

    it 'responds to explain' do
      expect(client).to respond_to(:explain)
    end

    it 'responds to counterfactual' do
      expect(client).to respond_to(:counterfactual)
    end

    it 'can perform a full schema workflow' do
      client.learn_relation(cause: :rain, effect: :wet_ground, relation_type: :causes, confidence: 0.8)
      client.learn_relation(cause: :wet_ground, effect: :slip, relation_type: :causes, confidence: 0.7)
      client.learn_relation(cause: :slip, effect: :injury, relation_type: :causes, confidence: 0.6)

      explanation = client.explain(outcome: :injury)
      expect(explanation[:chain]).not_to be_empty

      counterfactual = client.counterfactual(cause: :rain)
      expect(counterfactual[:affected].size).to be >= 2

      stats = client.schema_stats
      expect(stats[:relation_count]).to eq(3)
    end
  end
end

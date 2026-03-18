# frozen_string_literal: true

require 'legion/extensions/agentic/inference/gravity/client'

RSpec.describe Legion::Extensions::Agentic::Inference::Gravity::Runners::Gravity do
  let(:client) { Legion::Extensions::Agentic::Inference::Gravity::Client.new }
  let(:engine) { Legion::Extensions::Agentic::Inference::Gravity::Helpers::GravityEngine.new }

  describe '#create_attractor' do
    it 'creates an attractor with valid domain' do
      result = client.create_attractor(content: 'deep worry', domain: :anxiety)
      expect(result[:success]).to be true
      expect(result[:attractor][:content]).to eq('deep worry')
      expect(result[:attractor][:domain]).to eq(:anxiety)
    end

    it 'returns error for invalid domain' do
      result = client.create_attractor(content: 'x', domain: :invalid_domain)
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:invalid_domain)
    end

    it 'accepts injected engine via keyword' do
      result = client.create_attractor(content: 'injected', domain: :problem, engine: engine)
      expect(result[:success]).to be true
      expect(engine.attractors.size).to eq(1)
    end

    it 'includes attractor hash in result' do
      result = client.create_attractor(content: 'test', domain: :curiosity)
      attractor = result[:attractor]
      expect(attractor).to include(:id, :mass, :domain)
    end
  end

  describe '#add_thought' do
    let!(:attractor_id) do
      client.create_attractor(content: 'center', domain: :problem)[:attractor][:id]
    end

    it 'adds a thought to an existing attractor' do
      result = client.add_thought(content: 'orbiting concern', attractor_id: attractor_id)
      expect(result[:success]).to be true
      expect(result[:thought][:content]).to eq('orbiting concern')
    end

    it 'returns error for nonexistent attractor' do
      result = client.add_thought(content: 'orphan', attractor_id: 'nonexistent-id')
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:attractor_not_found)
    end

    it 'accepts injected engine via keyword' do
      a = engine.add_attractor(content: 'center', domain: :problem)
      result = client.add_thought(content: 'orbit', attractor_id: a.id, engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '#tick_gravity' do
    it 'returns tick_processed true' do
      result = client.tick_gravity
      expect(result[:success]).to be true
      expect(result[:tick_processed]).to be true
    end

    it 'returns empty captures and escapes when no thoughts' do
      result = client.tick_gravity
      expect(result[:captures]).to eq([])
      expect(result[:escapes]).to eq([])
    end

    it 'uses injected engine' do
      result = client.tick_gravity(engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '#accrete' do
    let!(:attractor_id) do
      client.create_attractor(content: 'growing', domain: :obsession)[:attractor][:id]
    end

    it 'accretes an attractor' do
      result = client.accrete(attractor_id: attractor_id)
      expect(result[:success]).to be true
      expect(result[:accreted]).to be true
    end

    it 'returns error for unknown attractor' do
      result = client.accrete(attractor_id: 'nonexistent')
      expect(result[:success]).to be false
    end

    it 'accepts custom amount' do
      result = client.accrete(attractor_id: attractor_id, amount: 0.5)
      expect(result[:mass]).to be_within(0.001).of(1.5)
    end
  end

  describe '#erode' do
    let!(:attractor_id) do
      client.create_attractor(content: 'fading', domain: :fear)[:attractor][:id]
    end

    it 'erodes an attractor' do
      result = client.erode(attractor_id: attractor_id)
      expect(result[:success]).to be true
      expect(result[:eroded]).to be true
    end

    it 'returns error for unknown attractor' do
      result = client.erode(attractor_id: 'nonexistent')
      expect(result[:success]).to be false
    end
  end

  describe '#strongest_attractors' do
    before do
      client.create_attractor(content: 'heavy', domain: :obsession, mass: 2.5)
      client.create_attractor(content: 'light', domain: :curiosity, mass: 0.5)
    end

    it 'returns attractors sorted by mass' do
      result = client.strongest_attractors
      expect(result[:success]).to be true
      expect(result[:attractors].first[:mass]).to be > result[:attractors].last[:mass]
    end

    it 'respects the limit' do
      result = client.strongest_attractors(limit: 1)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#thought_distribution' do
    it 'returns a distribution hash' do
      result = client.thought_distribution
      expect(result[:success]).to be true
      expect(result[:distribution]).to be_a(Hash)
    end
  end

  describe '#cognitive_density_map' do
    it 'returns a density map hash' do
      result = client.cognitive_density_map
      expect(result[:success]).to be true
      expect(result[:density_map]).to be_a(Hash)
    end
  end

  describe '#gravity_report' do
    it 'returns a full report' do
      result = client.gravity_report
      expect(result[:success]).to be true
      expect(result[:report]).to include(:total_attractors, :total_orbiting)
    end
  end
end

# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Momentum::Runners::CognitiveMomentum do
  let(:client) { Legion::Extensions::Agentic::Inference::Momentum::Helpers::Client.new }

  describe '#create_cognitive_idea' do
    it 'creates an idea' do
      result = client.create_cognitive_idea(content: 'test', idea_type: :belief, domain: :work)
      expect(result[:success]).to be true
      expect(result[:idea][:content]).to eq('test')
    end
  end

  describe '#reinforce_cognitive_idea' do
    it 'reinforces an idea' do
      created = client.create_cognitive_idea(content: 'x', idea_type: :goal, domain: :d)
      result = client.reinforce_cognitive_idea(idea_id: created[:idea][:id])
      expect(result[:success]).to be true
      expect(result[:momentum]).to be > 0
    end
  end

  describe '#challenge_cognitive_idea' do
    it 'challenges an idea' do
      created = client.create_cognitive_idea(content: 'x', idea_type: :goal, domain: :d)
      client.reinforce_cognitive_idea(idea_id: created[:idea][:id])
      result = client.challenge_cognitive_idea(idea_id: created[:idea][:id])
      expect(result[:success]).to be true
    end
  end

  describe '#apply_cognitive_force' do
    it 'applies force' do
      created = client.create_cognitive_idea(content: 'x', idea_type: :belief, domain: :d)
      result = client.apply_cognitive_force(idea_id: created[:idea][:id], force: 0.3)
      expect(result[:success]).to be true
      expect(result[:velocity]).to be > 0
    end
  end

  describe '#surging_ideas_report' do
    it 'returns surging ideas' do
      created = client.create_cognitive_idea(content: 'x', idea_type: :belief, domain: :d)
      10.times { client.reinforce_cognitive_idea(idea_id: created[:idea][:id]) }
      result = client.surging_ideas_report
      expect(result[:success]).to be true
      expect(result[:count]).to be >= 1
    end
  end

  describe '#reversing_ideas_report' do
    it 'returns reversing ideas' do
      result = client.reversing_ideas_report
      expect(result[:success]).to be true
    end
  end

  describe '#entrenched_ideas_report' do
    it 'returns entrenched ideas' do
      result = client.entrenched_ideas_report
      expect(result[:success]).to be true
    end
  end

  describe '#highest_momentum_ideas' do
    it 'returns top momentum ideas' do
      client.create_cognitive_idea(content: 'a', idea_type: :belief, domain: :d)
      result = client.highest_momentum_ideas(limit: 3)
      expect(result[:success]).to be true
    end
  end

  describe '#ideas_by_domain' do
    it 'filters by domain' do
      client.create_cognitive_idea(content: 'a', idea_type: :belief, domain: :work)
      result = client.ideas_by_domain(domain: :work)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#update_cognitive_momentum' do
    it 'applies friction and prunes' do
      result = client.update_cognitive_momentum
      expect(result[:success]).to be true
      expect(result).to have_key(:pruned)
    end
  end

  describe '#cognitive_momentum_stats' do
    it 'returns stats' do
      result = client.cognitive_momentum_stats
      expect(result[:success]).to be true
      expect(result).to include(:total_ideas, :surging_count)
    end
  end
end

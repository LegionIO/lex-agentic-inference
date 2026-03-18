# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Momentum::Helpers::MomentumEngine do
  subject(:engine) { described_class.new }

  let(:idea) { engine.create_idea(content: 'test', idea_type: :belief, domain: :general) }

  describe '#create_idea' do
    it 'creates and stores an idea' do
      result = engine.create_idea(content: 'hello', idea_type: :goal, domain: :work)
      expect(result).to be_a(Legion::Extensions::Agentic::Inference::Momentum::Helpers::Idea)
      expect(result.content).to eq('hello')
    end

    it 'records history' do
      engine.create_idea(content: 'x', idea_type: :belief, domain: :d)
      expect(engine.history.last[:event]).to eq(:created)
    end

    it 'evicts oldest when at capacity' do
      max = Legion::Extensions::Agentic::Inference::Momentum::Helpers::Constants::MAX_IDEAS
      max.times { |idx| engine.create_idea(content: "idea_#{idx}", idea_type: :belief, domain: :d) }
      engine.create_idea(content: 'overflow', idea_type: :belief, domain: :d)
      expect(engine.to_h[:total_ideas]).to eq(max)
    end
  end

  describe '#reinforce_idea' do
    it 'reinforces an existing idea' do
      result = engine.reinforce_idea(idea_id: idea.id)
      expect(result[:success]).to be true
      expect(result[:momentum]).to be > 0
    end

    it 'returns not_found for missing idea' do
      result = engine.reinforce_idea(idea_id: 'missing')
      expect(result[:success]).to be false
    end
  end

  describe '#challenge_idea' do
    it 'challenges an existing idea' do
      idea
      engine.reinforce_idea(idea_id: idea.id)
      result = engine.challenge_idea(idea_id: idea.id)
      expect(result[:success]).to be true
    end
  end

  describe '#apply_force' do
    it 'applies force to an idea' do
      result = engine.apply_force(idea_id: idea.id, force: 0.2)
      expect(result[:success]).to be true
      expect(result[:velocity]).to be > 0
    end

    it 'returns not_found for missing idea' do
      result = engine.apply_force(idea_id: 'missing', force: 0.1)
      expect(result[:success]).to be false
    end
  end

  describe '#surging_ideas' do
    it 'returns ideas with high momentum' do
      10.times { engine.reinforce_idea(idea_id: idea.id) }
      expect(engine.surging_ideas).to include(idea)
    end

    it 'excludes low momentum ideas' do
      idea
      expect(engine.surging_ideas).to be_empty
    end
  end

  describe '#reversing_ideas' do
    it 'returns ideas with negative momentum' do
      5.times { engine.challenge_idea(idea_id: idea.id) }
      expect(engine.reversing_ideas).to include(idea)
    end
  end

  describe '#entrenched_ideas' do
    it 'returns ideas with high mass' do
      10.times { engine.reinforce_idea(idea_id: idea.id) }
      expect(engine.entrenched_ideas).to include(idea)
    end
  end

  describe '#ideas_by_type' do
    it 'filters by idea type' do
      engine.create_idea(content: 'a', idea_type: :goal, domain: :d)
      engine.create_idea(content: 'b', idea_type: :belief, domain: :d)
      expect(engine.ideas_by_type(idea_type: :goal).size).to eq(1)
    end
  end

  describe '#ideas_by_domain' do
    it 'filters by domain' do
      engine.create_idea(content: 'a', idea_type: :belief, domain: :work)
      engine.create_idea(content: 'b', idea_type: :belief, domain: :play)
      expect(engine.ideas_by_domain(domain: :work).size).to eq(1)
    end
  end

  describe '#highest_momentum' do
    it 'returns ideas sorted by momentum desc' do
      engine.create_idea(content: 'low', idea_type: :belief, domain: :d)
      high = engine.create_idea(content: 'high', idea_type: :belief, domain: :d)
      5.times { engine.reinforce_idea(idea_id: high.id) }
      result = engine.highest_momentum(limit: 2)
      expect(result.first).to eq(high)
    end
  end

  describe '#most_entrenched' do
    it 'returns ideas sorted by mass desc' do
      engine.create_idea(content: 'light', idea_type: :belief, domain: :d)
      heavy = engine.create_idea(content: 'heavy', idea_type: :belief, domain: :d, mass: 0.9)
      result = engine.most_entrenched(limit: 2)
      expect(result.first).to eq(heavy)
    end
  end

  describe '#apply_friction_all' do
    it 'reduces velocity on all ideas' do
      engine.reinforce_idea(idea_id: idea.id)
      old_velocity = idea.velocity
      engine.apply_friction_all
      expect(idea.velocity).to be < old_velocity
    end
  end

  describe '#prune_at_rest' do
    it 'removes at-rest minimal-mass ideas' do
      engine.create_idea(content: 'light', idea_type: :belief, domain: :d, mass: 0.1)
      expect(engine.prune_at_rest).to eq(1)
    end

    it 'does not prune ideas with mass' do
      idea
      expect(engine.prune_at_rest).to eq(0)
    end
  end

  describe '#to_h' do
    it 'returns stats hash' do
      idea
      stats = engine.to_h
      expect(stats).to include(:total_ideas, :surging_count, :reversing_count,
                               :entrenched_count, :avg_momentum, :history_count)
      expect(stats[:total_ideas]).to eq(1)
    end
  end
end

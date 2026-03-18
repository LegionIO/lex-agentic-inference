# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Inference::Gravity::Helpers::GravityEngine do
  subject(:engine) { described_class.new }

  describe '#add_attractor' do
    it 'creates and stores an attractor' do
      result = engine.add_attractor(content: 'test', domain: :curiosity)
      expect(result).to be_a(Legion::Extensions::Agentic::Inference::Gravity::Helpers::Attractor)
      expect(engine.attractors.size).to eq(1)
    end

    it 'returns error when at capacity' do
      stub_const('Legion::Extensions::Agentic::Inference::Gravity::Helpers::Constants::MAX_ATTRACTORS', 1)
      engine.add_attractor(content: 'first', domain: :problem)
      result = engine.add_attractor(content: 'second', domain: :problem)
      expect(result[:error]).to eq(:capacity_exceeded)
    end
  end

  describe '#add_orbiting_thought' do
    let(:attractor) { engine.add_attractor(content: 'center', domain: :problem) }

    it 'creates and stores an orbiting thought' do
      result = engine.add_orbiting_thought(content: 'orbit', attractor_id: attractor.id)
      expect(result).to be_a(Legion::Extensions::Agentic::Inference::Gravity::Helpers::OrbitingThought)
      expect(engine.orbiting_thoughts.size).to eq(1)
    end

    it 'returns error for unknown attractor' do
      result = engine.add_orbiting_thought(content: 'orphan', attractor_id: 'nonexistent')
      expect(result[:error]).to eq(:attractor_not_found)
    end

    it 'returns error when orbiting capacity exceeded' do
      stub_const('Legion::Extensions::Agentic::Inference::Gravity::Helpers::Constants::MAX_ORBITING', 1)
      engine.add_orbiting_thought(content: 'first', attractor_id: attractor.id)
      result = engine.add_orbiting_thought(content: 'second', attractor_id: attractor.id)
      expect(result[:error]).to eq(:capacity_exceeded)
    end
  end

  describe '#simulate_tick' do
    let!(:attractor) { engine.add_attractor(content: 'pull', domain: :obsession, mass: 2.0, pull_radius: 2.0) }

    it 'returns tick_processed true' do
      result = engine.simulate_tick
      expect(result[:tick_processed]).to be true
    end

    it 'pulls orbiting thoughts closer' do
      thought = engine.add_orbiting_thought(
        content: 'drawn in', attractor_id: attractor.id, orbital_distance: 0.5
      )
      initial_distance = thought.orbital_distance
      engine.simulate_tick
      expect(thought.orbital_distance).to be < initial_distance
    end

    it 'detects capture events when thought crosses capture radius' do
      engine.add_orbiting_thought(
        content: 'almost captured', attractor_id: attractor.id, orbital_distance: 0.3
      )
      result = engine.simulate_tick
      expect(result[:captures].size).to be >= 1
    end

    it 'does not pull thoughts beyond pull_radius' do
      thought = engine.add_orbiting_thought(
        content: 'far away', attractor_id: attractor.id, orbital_distance: 3.0
      )
      engine.simulate_tick
      expect(thought.orbital_distance).to eq(3.0)
    end

    it 'skips collapsed attractors' do
      collapsed = engine.add_attractor(content: 'collapsed', domain: :fear, mass: 0.05)
      thought = engine.add_orbiting_thought(
        content: 'near collapsed', attractor_id: collapsed.id, orbital_distance: 0.5
      )
      engine.simulate_tick
      expect(thought.orbital_distance).to eq(0.5)
    end
  end

  describe '#accrete_attractor' do
    let!(:attractor) { engine.add_attractor(content: 'grow', domain: :interest) }

    it 'increases attractor mass' do
      engine.accrete_attractor(attractor.id)
      expect(attractor.mass).to be_within(0.001).of(1.15)
    end

    it 'returns accreted true' do
      result = engine.accrete_attractor(attractor.id)
      expect(result[:accreted]).to be true
    end

    it 'returns error for unknown attractor' do
      result = engine.accrete_attractor('nonexistent')
      expect(result[:error]).to eq(:not_found)
    end
  end

  describe '#erode_attractor' do
    let!(:attractor) { engine.add_attractor(content: 'shrink', domain: :anxiety) }

    it 'decreases attractor mass' do
      engine.erode_attractor(attractor.id)
      expect(attractor.mass).to be_within(0.001).of(0.95)
    end

    it 'returns eroded true' do
      result = engine.erode_attractor(attractor.id)
      expect(result[:eroded]).to be true
    end

    it 'reports collapsed when mass drops below threshold' do
      a = engine.add_attractor(content: 'weak', domain: :fear, mass: 0.12)
      result = engine.erode_attractor(a.id, amount: 0.1)
      expect(result[:collapsed]).to be true
    end

    it 'returns error for unknown attractor' do
      result = engine.erode_attractor('nonexistent')
      expect(result[:error]).to eq(:not_found)
    end
  end

  describe '#strongest_attractors' do
    it 'returns attractors sorted by mass descending' do
      engine.add_attractor(content: 'light', domain: :curiosity, mass: 0.5)
      engine.add_attractor(content: 'heavy', domain: :obsession, mass: 2.5)
      engine.add_attractor(content: 'medium', domain: :interest, mass: 1.2)
      results = engine.strongest_attractors(limit: 3)
      masses = results.map(&:mass)
      expect(masses).to eq(masses.sort.reverse)
    end

    it 'excludes collapsed attractors' do
      engine.add_attractor(content: 'alive', domain: :curiosity, mass: 1.5)
      engine.add_attractor(content: 'dead', domain: :fear, mass: 0.05)
      results = engine.strongest_attractors
      expect(results.none?(&:collapsed?)).to be true
    end

    it 'respects the limit parameter' do
      5.times { |i| engine.add_attractor(content: "attractor #{i}", domain: :problem) }
      results = engine.strongest_attractors(limit: 3)
      expect(results.size).to eq(3)
    end
  end

  describe '#thought_distribution' do
    it 'returns a hash of attractor_id => count' do
      a1 = engine.add_attractor(content: 'a1', domain: :problem)
      a2 = engine.add_attractor(content: 'a2', domain: :curiosity)
      engine.add_orbiting_thought(content: 't1', attractor_id: a1.id)
      engine.add_orbiting_thought(content: 't2', attractor_id: a1.id)
      engine.add_orbiting_thought(content: 't3', attractor_id: a2.id)
      distribution = engine.thought_distribution
      expect(distribution[a1.id]).to eq(2)
      expect(distribution[a2.id]).to eq(1)
    end
  end

  describe '#cognitive_density_map' do
    it 'returns density labels per attractor' do
      a = engine.add_attractor(content: 'a', domain: :interest)
      engine.add_orbiting_thought(content: 't', attractor_id: a.id)
      density_map = engine.cognitive_density_map
      expect(density_map[a.id]).to be_a(Symbol)
    end
  end

  describe '#gravity_report' do
    it 'returns a comprehensive report hash' do
      report = engine.gravity_report
      expect(report).to include(:total_attractors, :active_attractors, :collapsed_attractors,
                                :supermassive_count, :total_orbiting, :captured_count,
                                :escaped_count, :total_captures, :total_escapes, :strongest)
    end

    it 'counts attractors correctly' do
      engine.add_attractor(content: 'active', domain: :curiosity)
      engine.add_attractor(content: 'collapsed', domain: :fear, mass: 0.05)
      report = engine.gravity_report
      expect(report[:total_attractors]).to eq(2)
      expect(report[:collapsed_attractors]).to eq(1)
      expect(report[:active_attractors]).to eq(1)
    end
  end
end

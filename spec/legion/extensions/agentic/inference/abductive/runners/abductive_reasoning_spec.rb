# frozen_string_literal: true

require 'legion/extensions/agentic/inference/abductive/client'

RSpec.describe Legion::Extensions::Agentic::Inference::Abductive::Runners::AbductiveReasoning do
  let(:client) { Legion::Extensions::Agentic::Inference::Abductive::Client.new }

  describe '#record_observation' do
    it 'records an observation and returns success' do
      result = client.record_observation(
        content:        'CPU usage spiked to 100% unexpectedly',
        domain:         :system_health,
        surprise_level: :surprising
      )
      expect(result[:success]).to be true
      expect(result[:observation][:id]).to match(/\A[0-9a-f-]{36}\z/)
      expect(result[:observation][:domain]).to eq(:system_health)
      expect(result[:observation][:surprise_level]).to eq(:surprising)
    end

    it 'rejects invalid surprise level' do
      result = client.record_observation(
        content:        'some fact',
        domain:         :test,
        surprise_level: :unknown_level
      )
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:invalid_surprise_level)
      expect(result[:valid_levels]).to eq(Legion::Extensions::Agentic::Inference::Abductive::Helpers::Constants::SURPRISE_LEVELS)
    end

    it 'uses notable as default surprise level' do
      result = client.record_observation(content: 'a fact', domain: :test)
      expect(result[:observation][:surprise_level]).to eq(:notable)
    end

    it 'stores context hash' do
      result = client.record_observation(
        content: 'memory leak detected',
        domain:  :system,
        context: { pid: 1234, rss_mb: 4096 }
      )
      expect(result[:observation][:context]).to eq({ pid: 1234, rss_mb: 4096 })
    end
  end

  describe '#generate_hypothesis' do
    let(:obs_result) { client.record_observation(content: 'service crashed', domain: :ops) }
    let(:obs_id)     { obs_result[:observation][:id] }

    it 'generates a hypothesis and returns success' do
      result = client.generate_hypothesis(
        content:           'Memory leak caused service crash',
        observation_ids:   [obs_id],
        domain:            :ops,
        simplicity:        0.7,
        explanatory_power: 0.8
      )
      expect(result[:success]).to be true
      expect(result[:hypothesis][:id]).to match(/\A[0-9a-f-]{36}\z/)
      expect(result[:hypothesis][:state]).to eq(:candidate)
      expect(result[:hypothesis][:overall_score]).to be > 0
    end

    it 'uses default prior probability when not given' do
      result = client.generate_hypothesis(
        content:           'Network partition caused crash',
        observation_ids:   [obs_id],
        domain:            :ops,
        simplicity:        0.5,
        explanatory_power: 0.6
      )
      expect(result[:hypothesis][:prior_probability]).to eq(
        Legion::Extensions::Agentic::Inference::Abductive::Helpers::Constants::DEFAULT_PLAUSIBILITY
      )
    end

    it 'uses provided prior probability' do
      result = client.generate_hypothesis(
        content:           'Config error',
        observation_ids:   [obs_id],
        domain:            :ops,
        simplicity:        0.9,
        explanatory_power: 0.7,
        prior_probability: 0.8
      )
      expect(result[:hypothesis][:prior_probability]).to eq(0.8)
    end
  end

  describe '#evaluate_hypothesis' do
    let(:obs_id) { client.record_observation(content: 'anomaly', domain: :test)[:observation][:id] }
    let(:hyp_id) do
      client.generate_hypothesis(
        content:           'hypothesis A',
        observation_ids:   [obs_id],
        domain:            :test,
        simplicity:        0.8,
        explanatory_power: 0.9
      )[:hypothesis][:id]
    end

    it 'evaluates a known hypothesis' do
      result = client.evaluate_hypothesis(hypothesis_id: hyp_id)
      expect(result[:success]).to be true
      expect(result[:score]).to be_a(Float)
      expect(result[:rank]).to be >= 1
      expect(result[:quality_label]).to be_a(Symbol)
    end

    it 'returns not_found for unknown hypothesis' do
      result = client.evaluate_hypothesis(hypothesis_id: 'nonexistent-id')
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:not_found)
    end
  end

  describe '#add_hypothesis_evidence' do
    let(:obs_id) { client.record_observation(content: 'strange output', domain: :test)[:observation][:id] }
    let(:hyp_id) do
      client.generate_hypothesis(
        content:           'bad config',
        observation_ids:   [obs_id],
        domain:            :test,
        simplicity:        0.6,
        explanatory_power: 0.7
      )[:hypothesis][:id]
    end

    it 'adds supporting evidence and boosts plausibility' do
      before_plausibility = client.evaluate_hypothesis(hypothesis_id: hyp_id)[:score]
      client.add_hypothesis_evidence(hypothesis_id: hyp_id, supporting: true)
      hyp_after = client.evaluate_hypothesis(hypothesis_id: hyp_id)
      expect(hyp_after[:success]).to be true
      expect(before_plausibility).to be_a(Float)
    end

    it 'transitions to supported after enough supporting evidence' do
      3.times { client.add_hypothesis_evidence(hypothesis_id: hyp_id, supporting: true) }
      result = client.add_hypothesis_evidence(hypothesis_id: hyp_id, supporting: true)
      expect(result[:state]).to eq(:supported)
    end

    it 'adds contradicting evidence' do
      result = client.add_hypothesis_evidence(hypothesis_id: hyp_id, supporting: false)
      expect(result[:success]).to be true
      expect(result[:state]).to eq(:candidate)
    end

    it 'returns not_found for unknown hypothesis' do
      result = client.add_hypothesis_evidence(hypothesis_id: 'missing', supporting: true)
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:not_found)
    end
  end

  describe '#best_explanation' do
    let(:obs_id) { client.record_observation(content: 'disk full warning', domain: :storage)[:observation][:id] }

    it 'returns nil found when no hypotheses exist' do
      result = client.best_explanation(observation_id: obs_id)
      expect(result[:success]).to be true
      expect(result[:found]).to be false
    end

    it 'returns best hypothesis by overall_score' do
      client.generate_hypothesis(
        content:           'log files grew unbounded',
        observation_ids:   [obs_id],
        domain:            :storage,
        simplicity:        0.9,
        explanatory_power: 0.9,
        prior_probability: 0.8
      )
      client.generate_hypothesis(
        content:           'backup job failed and left temp files',
        observation_ids:   [obs_id],
        domain:            :storage,
        simplicity:        0.3,
        explanatory_power: 0.4,
        prior_probability: 0.2
      )
      result = client.best_explanation(observation_id: obs_id)
      expect(result[:success]).to be true
      expect(result[:found]).to be true
      expect(result[:hypothesis][:content]).to eq('log files grew unbounded')
    end
  end

  describe '#competing_hypotheses' do
    let(:obs_id) { client.record_observation(content: 'latency spike', domain: :perf)[:observation][:id] }

    it 'returns empty list when no hypotheses' do
      result = client.competing_hypotheses(observation_id: obs_id)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(0)
      expect(result[:hypotheses]).to eq([])
    end

    it 'returns hypotheses sorted by score descending' do
      client.generate_hypothesis(
        content:           'DB slow query',
        observation_ids:   [obs_id],
        domain:            :perf,
        simplicity:        0.8,
        explanatory_power: 0.8
      )
      client.generate_hypothesis(
        content:           'Network congestion',
        observation_ids:   [obs_id],
        domain:            :perf,
        simplicity:        0.2,
        explanatory_power: 0.2
      )
      result = client.competing_hypotheses(observation_id: obs_id)
      expect(result[:count]).to eq(2)
      scores = result[:hypotheses].map { |h| h[:overall_score] }
      expect(scores).to eq(scores.sort.reverse)
    end
  end

  describe '#refute_hypothesis' do
    let(:obs_id) { client.record_observation(content: 'error 500', domain: :web)[:observation][:id] }
    let(:hyp_id) do
      client.generate_hypothesis(
        content:           'out of memory',
        observation_ids:   [obs_id],
        domain:            :web,
        simplicity:        0.5,
        explanatory_power: 0.5
      )[:hypothesis][:id]
    end

    it 'refutes a hypothesis' do
      result = client.refute_hypothesis(hypothesis_id: hyp_id)
      expect(result[:success]).to be true
      expect(result[:state]).to eq(:refuted)
    end

    it 'excludes refuted hypotheses from competing list' do
      client.refute_hypothesis(hypothesis_id: hyp_id)
      result = client.competing_hypotheses(observation_id: obs_id)
      expect(result[:count]).to eq(0)
    end

    it 'returns not_found for unknown hypothesis' do
      result = client.refute_hypothesis(hypothesis_id: 'ghost')
      expect(result[:success]).to be false
      expect(result[:error]).to eq(:not_found)
    end
  end

  describe '#unexplained_observations' do
    it 'returns observations with no supported hypothesis' do
      client.record_observation(content: 'unexplained event', domain: :mystery)
      result = client.unexplained_observations
      expect(result[:success]).to be true
      expect(result[:count]).to be >= 1
    end

    it 'excludes observations explained by a supported hypothesis' do
      obs_id = client.record_observation(content: 'explained', domain: :test)[:observation][:id]
      hyp_id = client.generate_hypothesis(
        content:           'known cause',
        observation_ids:   [obs_id],
        domain:            :test,
        simplicity:        0.9,
        explanatory_power: 0.9
      )[:hypothesis][:id]
      3.times { client.add_hypothesis_evidence(hypothesis_id: hyp_id, supporting: true) }
      client.add_hypothesis_evidence(hypothesis_id: hyp_id, supporting: true)

      result = client.unexplained_observations
      obs_ids = result[:observations].map { |o| o[:id] }
      expect(obs_ids).not_to include(obs_id)
    end
  end

  describe '#update_abductive_reasoning' do
    it 'runs decay and prune cycle' do
      result = client.update_abductive_reasoning
      expect(result[:success]).to be true
      expect(result[:decayed]).to be >= 0
      expect(result[:pruned]).to be >= 0
    end

    it 'prunes refuted hypotheses' do
      obs_id = client.record_observation(content: 'obs', domain: :test)[:observation][:id]
      hyp_id = client.generate_hypothesis(
        content:           'bad hyp',
        observation_ids:   [obs_id],
        domain:            :test,
        simplicity:        0.5,
        explanatory_power: 0.5
      )[:hypothesis][:id]
      client.refute_hypothesis(hypothesis_id: hyp_id)

      result = client.update_abductive_reasoning
      expect(result[:pruned]).to eq(1)
    end
  end

  describe '#abductive_reasoning_stats' do
    it 'returns stats hash' do
      result = client.abductive_reasoning_stats
      expect(result[:success]).to be true
      expect(result).to have_key(:observation_count)
      expect(result).to have_key(:hypothesis_count)
      expect(result).to have_key(:supported_count)
      expect(result).to have_key(:refuted_count)
      expect(result).to have_key(:candidate_count)
      expect(result).to have_key(:unexplained_count)
    end

    it 'reflects accumulated state' do
      client.record_observation(content: 'fact', domain: :test)
      result = client.abductive_reasoning_stats
      expect(result[:observation_count]).to be >= 1
    end
  end

  describe 'quality labels' do
    let(:obs_id) { client.record_observation(content: 'obs', domain: :test)[:observation][:id] }

    it 'assigns compelling label for high-scoring hypothesis' do
      result = client.generate_hypothesis(
        content:           'strong hypothesis',
        observation_ids:   [obs_id],
        domain:            :test,
        simplicity:        1.0,
        explanatory_power: 1.0,
        prior_probability: 1.0
      )
      expect(result[:hypothesis][:quality_label]).to eq(:compelling)
    end

    it 'assigns implausible label for low-scoring hypothesis' do
      result = client.generate_hypothesis(
        content:           'weak hypothesis',
        observation_ids:   [obs_id],
        domain:            :test,
        simplicity:        0.0,
        explanatory_power: 0.0,
        prior_probability: 0.0
      )
      expect(result[:hypothesis][:quality_label]).to eq(:implausible)
    end
  end
end

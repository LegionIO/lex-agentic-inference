# frozen_string_literal: true

# Stub the base class before loading the actor
module Legion
  module Extensions
    module Actors
      class Every; end # rubocop:disable Lint/EmptyClass
    end
  end
end

$LOADED_FEATURES << 'legion/extensions/actors/every'

require_relative '../../../../../../../lib/legion/extensions/agentic/inference/reality_testing/actors/decay_beliefs'

RSpec.describe Legion::Extensions::Agentic::Inference::RealityTesting::Actor::DecayBeliefs do
  subject(:actor) { described_class.new }

  describe '#runner_class' do
    it do
      expect(actor.runner_class).to eq Legion::Extensions::Agentic::Inference::RealityTesting::Runners::RealityTesting
    end
  end

  describe '#runner_function' do
    it { expect(actor.runner_function).to eq 'decay_beliefs' }
  end

  describe '#time' do
    it { expect(actor.time).to eq 300 }
  end

  describe '#run_now?' do
    it { expect(actor.run_now?).to be false }
  end

  describe '#use_runner?' do
    it { expect(actor.use_runner?).to be false }
  end

  describe '#check_subtask?' do
    it { expect(actor.check_subtask?).to be false }
  end

  describe '#generate_task?' do
    it { expect(actor.generate_task?).to be false }
  end
end

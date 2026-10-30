# frozen_string_literal: true

require 'legion/extensions/agentic/inference/prediction/client'

RSpec.describe Legion::Extensions::Agentic::Inference::Prediction::Runners::Prediction do
  let(:client) { Legion::Extensions::Agentic::Inference::Prediction::Client.new(prediction_stores: {}) }

  describe 'per-identity isolation' do
    it 'predictions for identity X are not visible to identity Y' do
      result_x = client.predict(mode: :fault_localization, identity: 'alice')
      result_y = client.get_prediction(prediction_id: result_x[:prediction_id], identity: 'bob')
      expect(result_y[:found]).to be false
    end

    it 'accuracy for X is independent of Y outcomes' do
      3.times do
        pred = client.predict(mode: :fault_localization, identity: 'alice')
        client.resolve_prediction(prediction_id: pred[:prediction_id], outcome: :correct, identity: 'alice')
      end
      3.times do
        pred = client.predict(mode: :fault_localization, identity: 'bob')
        client.resolve_prediction(prediction_id: pred[:prediction_id], outcome: :incorrect, identity: 'bob')
      end

      acc_alice = client.prediction_accuracy(identity: 'alice')
      acc_bob = client.prediction_accuracy(identity: 'bob')

      expect(acc_alice[:accuracy]).to eq(1.0)
      expect(acc_bob[:accuracy]).to eq(0.0)
    end

    it 'pending count for X does not include Y predictions' do
      client.predict(mode: :fault_localization, identity: 'alice')
      pred_bob = client.predict(mode: :fault_localization, identity: 'bob')
      client.resolve_prediction(prediction_id: pred_bob[:prediction_id], outcome: :correct, identity: 'bob')

      alice_pending = client.pending_predictions(identity: 'alice')
      bob_pending = client.pending_predictions(identity: 'bob')

      expect(alice_pending[:count]).to eq(1)
      expect(bob_pending[:count]).to eq(0)
    end
  end

  describe 'shared runtime state' do
    let(:identity) { SecureRandom.uuid }
    let(:other_identity) { SecureRandom.uuid }
    let(:producer) { Legion::Extensions::Agentic::Inference::Prediction::Client.new }
    let(:consumer) { Object.new.extend(described_class) }

    after do
      producer.erase_partner!(identity: identity)
      producer.erase_partner!(identity: other_identity)
    end

    it 'resolves a client prediction through separate runner instances without crossing identities' do
      prediction = producer.predict(mode: :functional_mapping, confidence: 0.9, identity: identity)
      other = producer.predict(mode: :functional_mapping, identity: other_identity)

      expect(consumer.pending_predictions(identity: identity)[:predictions].map { |entry| entry[:prediction_id] })
        .to eq([prediction[:prediction_id]])
      expect(consumer.resolve_prediction(prediction_id: prediction[:prediction_id], outcome: :incorrect,
                                         identity: other_identity)).to include(resolved: false, reason: :not_found)

      resolver = Object.new.extend(described_class)
      resolver.resolve_prediction(prediction_id: prediction[:prediction_id], outcome: :correct, identity: identity)

      expect(producer.prediction_accuracy(identity: identity)).to eq(accuracy: 1.0, total_outcomes: 1)
      expect(producer.pending_predictions(identity: identity)[:predictions]).to be_empty
      expect(consumer.get_prediction(prediction_id: other[:prediction_id], identity: other_identity)[:prediction])
        .to include(status: :pending)
      consumer.erase_partner!(identity: identity)
      expect(producer.get_prediction(prediction_id: prediction[:prediction_id], identity: identity)[:found]).to be false
    end
  end

  describe '#erase_partner!' do
    it 'removes all predictions and outcomes for the identity' do
      3.times do
        pred = client.predict(mode: :fault_localization, identity: 'alice')
        client.resolve_prediction(prediction_id: pred[:prediction_id], outcome: :correct, identity: 'alice')
      end

      result = client.erase_partner!(identity: 'alice')
      expect(result[:erased]).to be true
      expect(result[:identity]).to eq('alice')

      expect(client.pending_predictions(identity: 'alice')[:count]).to eq(0)
      expect(client.prediction_accuracy(identity: 'alice')[:total_outcomes]).to eq(0)
    end

    it 'does not affect a different identity after erase' do
      3.times { client.predict(mode: :fault_localization, identity: 'bob') }
      client.erase_partner!(identity: 'alice')

      expect(client.pending_predictions(identity: 'bob')[:count]).to eq(3)
    end
  end

  describe '#client responds to erase_partner!' do
    it 'responds to erase_partner!' do
      expect(client).to respond_to(:erase_partner!)
    end
  end
end

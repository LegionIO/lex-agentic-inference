# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Inference::Prediction::Helpers::PredictionStore do
  let(:store_x) { described_class.new(identity: 'partner-X') }
  let(:store_y) { described_class.new(identity: 'partner-Y') }

  let(:basic_prediction) do
    {
      mode:        :fault_localization,
      confidence:  0.75,
      description: 'disk latency spike incoming',
      status:      :pending
    }
  end

  describe 'identity isolation — reads for X never see Y data' do
    it 'stores predictions under the correct identity' do
      id_x = store_x.store(basic_prediction.dup)
      expect(store_x.get(id_x)).not_to be_nil
      expect(store_y.get(id_x)).to be_nil
    end

    it 'X accuracy is independent of Y outcomes' do
      3.times do
        id = store_x.store(basic_prediction.dup)
        store_x.resolve(id, outcome: :correct)
      end
      3.times do
        id = store_y.store(basic_prediction.dup)
        store_y.resolve(id, outcome: :incorrect)
      end

      expect(store_x.accuracy).to eq(1.0)
      expect(store_y.accuracy).to eq(0.0)
    end

    it 'X pending predictions do not include Y predictions' do
      store_x.store(basic_prediction.dup)
      id_y = store_y.store(basic_prediction.dup)
      store_y.resolve(id_y, outcome: :correct)

      expect(store_x.pending.size).to eq(1)
      expect(store_y.pending.size).to eq(0)
    end

    it 'X count is independent of Y count' do
      3.times { store_x.store(basic_prediction.dup) }
      5.times { store_y.store(basic_prediction.dup) }

      expect(store_x.count).to eq(3)
      expect(store_y.count).to eq(5)
    end
  end

  describe '#identity' do
    it 'exposes the identity it was initialized with' do
      expect(store_x.identity).to eq('partner-X')
    end
  end

  describe '#erase_partner!' do
    it 'removes all predictions for the identity' do
      3.times { store_x.store(basic_prediction.dup) }
      store_x.erase_partner!(identity: 'partner-X')
      expect(store_x.count).to eq(0)
    end

    it 'removes all outcomes for the identity' do
      id = store_x.store(basic_prediction.dup)
      store_x.resolve(id, outcome: :correct)
      store_x.erase_partner!(identity: 'partner-X')
      expect(store_x.outcomes).to be_empty
    end

    it 'does not touch a different identity store' do
      id_x = store_x.store(basic_prediction.dup)
      store_x.resolve(id_x, outcome: :correct)

      3.times { store_y.store(basic_prediction.dup) }
      store_x.erase_partner!(identity: 'partner-X')

      expect(store_y.count).to eq(3)
    end

    it 'returns a confirmation hash' do
      result = store_x.erase_partner!(identity: 'partner-X')
      expect(result).to include(erased: true, identity: 'partner-X')
    end

    it 'raises ArgumentError when identity does not match own identity' do
      expect { store_x.erase_partner!(identity: 'partner-Y') }.to raise_error(ArgumentError)
    end
  end
end

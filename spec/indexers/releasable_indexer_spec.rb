# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReleasableIndexer do
  let(:apo_id) { 'druid:gf999hb9999' }

  let(:cocina) do
    Cocina::Models.build(
      'externalIdentifier' => 'druid:pz263ny9658',
      'type' => Cocina::Models::Vocab.image,
      'version' => 1,
      'label' => 'testing',
      'access' => {},
      'administrative' => administrative,
      'description' => {
        'title' => [{ 'value' => 'Test obj' }]
      },
      'structural' => {},
      'identification' => {
        'catalogLinks' => [{ 'catalog' => 'symphony', 'catalogRecordId' => '1234' }]
      }
    )
  end

  describe 'to_solr' do
    let(:doc) { described_class.new(cocina: cocina).to_solr }

    context 'when releaseTags are present' do
      let(:administrative) do
        {
          'hasAdminPolicy' => apo_id,
          'releaseTags' => [
            { 'to' => 'Project', 'release' => true, 'date' => '2016-11-16T22:52:35.000+00:00' },
            { 'to' => 'Project', 'release' => false, 'date' => '2016-12-21T17:31:18.000+00:00' },
            { 'to' => 'Project', 'release' => true, 'date' => '2021-05-12T21:05:21.000+00:00' },
            { 'to' => 'test_target', 'release' => true },
            { 'to' => 'test_nontarget', 'release' => false, 'date' => '2016-12-16T22:52:35.000+00:00' },
            { 'to' => 'test_nontarget', 'release' => true, 'date' => '2016-11-16T22:52:35.000+00:00' }
          ]
        }
      end

      it 'indexes release tags' do
        expect(doc).to eq('released_to_ssim' => %w[Project test_target])
      end
    end

    context 'when releaseTags are not present' do
      let(:administrative) do
        {
          'hasAdminPolicy' => apo_id
        }
      end

      it 'has no release tags' do
        expect(doc).not_to include('released_to_ssim')
      end
    end
  end
end

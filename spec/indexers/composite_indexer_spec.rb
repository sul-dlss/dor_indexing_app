# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompositeIndexer do
  let(:model) { Dor::Abstract }
  let(:druid) { 'druid:mx123ms3333' }
  let(:apo_id) { 'druid:gf999hb9999' }

  let(:apo) do
    Cocina::Models.build(
      'externalIdentifier' => apo_id,
      'type' => Cocina::Models::Vocab.admin_policy,
      'version' => 1,
      'label' => 'testing',
      'administrative' => {
        'hasAdminPolicy' => apo_id
      },
      'description' => {
        'title' => [{ 'value' => 'APO title' }]
      }
    )
  end

  let(:indexer) do
    described_class.new(
      DescriptiveMetadataIndexer,
      IdentifiableIndexer
    )
  end

  let(:cocina) do
    Cocina::Models.build(
      'externalIdentifier' => druid,
      'type' => Cocina::Models::Vocab.image,
      'version' => 1,
      'label' => 'testing',
      'access' => {},
      'administrative' => {
        'hasAdminPolicy' => apo_id
      },
      'description' => {
        'title' => [{ 'value' => 'Test obj' }],
        'subject' => [{ 'type' => 'topic', 'value' => 'word' }]
      },
      'structural' => {
        'contains' => []
      },
      'identification' => {
        'catalogLinks' => [{ 'catalog' => 'symphony', 'catalogRecordId' => '1234' }]
      }
    )
  end
  let(:object_client) { instance_double(Dor::Services::Client::Object, find: apo) }

  before do
    allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    allow(object_client).to receive_message_chain(:administrative_tags, :list).and_return([])
  end

  describe 'to_solr' do
    let(:status) do
      instance_double(Dor::Workflow::Client::Status, milestones: {}, info: {}, display: 'bad')
    end
    let(:workflow_client) { instance_double(Dor::Workflow::Client, status: status) }
    let(:doc) { indexer.new(id: 'druid:ab123cd4567', cocina: cocina).to_solr }

    before do
      allow(Dor::Workflow::Client).to receive(:new).and_return(workflow_client)
    end

    it 'calls each of the provided indexers and combines the results' do
      expect(doc).to eq(
        'metadata_format_ssim' => 'mods',
        'sw_display_title_tesim' => 'Test obj',
        'nonhydrus_apo_title_tesim' => ['APO title'],
        'nonhydrus_apo_title_ssim' => ['APO title'],
        'apo_title_tesim' => ['APO title'],
        'apo_title_ssim' => ['APO title'],
        'metadata_source_ssi' => 'Symphony',
        'objectId_tesim' => ['druid:mx123ms3333', 'mx123ms3333'],
        'topic_ssim' => ['word'],
        'topic_tesim' => ['word']
      )
    end
  end
end

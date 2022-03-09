# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataIndexer do
  let(:cocina) do
    Cocina::Models::DRO.new(externalIdentifier: 'druid:xx999xx9999',
                            type: Cocina::Models::ObjectType.map,
                            label: 'test label',
                            version: 4,
                            description: {
                              title: [{ value: 'test label' }],
                              purl: 'https://purl.stanford.edu/xx999xx9999'
                            },
                            access: {},
                            administrative: { hasAdminPolicy: 'druid:vv888vv8888' },
                            structural: structural)
  end

  before do
    allow(WorkflowFields).to receive(:for).and_return({ 'milestones_ssim' => %w[foo bar] })
  end

  describe '#to_solr' do
    let(:metadata) do
      instance_double(Dor::Services::Client::ObjectMetadata,
                      updated_at: 'Thu, 04 Mar 2021 23:05:34 GMT',
                      created_at: 'Wed, 01 Jan 2020 12:00:01 GMT')
    end
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(id: 'druid:ab123cd4567', cocina: cocina, metadata: metadata)
    end
    let(:doc) { indexer.to_solr }

    context 'with collections' do
      let(:structural) do
        { isMemberOf: ['druid:bb777bb7777', 'druid:dd666dd6666'] }
      end

      it 'makes a solr doc' do
        expect(doc).to eq(
          'obj_label_tesim' => 'test label',
          'current_version_isi' => 4,
          'milestones_ssim' => %w[foo bar],
          'has_constituents_ssim' => nil,
          'has_model_ssim' => 'info:fedora/afmodel:Dor_Item',
          'is_governed_by_ssim' => 'info:fedora/druid:vv888vv8888',
          'is_member_of_collection_ssim' => ['info:fedora/druid:bb777bb7777', 'info:fedora/druid:dd666dd6666'],
          'modified_latest_dttsi' => '2021-03-04T23:05:34Z',
          'created_at_dttsi' => '2020-01-01T12:00:01Z',
          :id => 'druid:xx999xx9999'
        )
      end
    end

    context 'with no collections' do
      let(:structural) do
        {}
      end

      it 'makes a solr doc' do
        expect(doc).to eq(
          'obj_label_tesim' => 'test label',
          'current_version_isi' => 4,
          'milestones_ssim' => %w[foo bar],
          'has_model_ssim' => 'info:fedora/afmodel:Dor_Item',
          'is_governed_by_ssim' => 'info:fedora/druid:vv888vv8888',
          'is_member_of_collection_ssim' => [],
          'has_constituents_ssim' => nil,
          'modified_latest_dttsi' => '2021-03-04T23:05:34Z',
          'created_at_dttsi' => '2020-01-01T12:00:01Z',
          :id => 'druid:xx999xx9999'
        )
      end
    end

    context 'with constituents' do
      let(:structural) do
        { hasMemberOrders: [{ members: ['druid:bb777bb7777', 'druid:dd666dd6666'] }] }
      end

      it 'makes a solr doc' do
        expect(doc).to eq(
          'obj_label_tesim' => 'test label',
          'current_version_isi' => 4,
          'milestones_ssim' => %w[foo bar],
          'has_constituents_ssim' => ['druid:bb777bb7777', 'druid:dd666dd6666'],
          'has_model_ssim' => 'info:fedora/afmodel:Dor_Item',
          'is_governed_by_ssim' => 'info:fedora/druid:vv888vv8888',
          'is_member_of_collection_ssim' => [],
          'modified_latest_dttsi' => '2021-03-04T23:05:34Z',
          'created_at_dttsi' => '2020-01-01T12:00:01Z',
          :id => 'druid:xx999xx9999'
        )
      end
    end
  end
end

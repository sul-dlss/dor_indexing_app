# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReindexJob do
  let(:message) { { model: model, created_at: 'Wed, 01 Jan 2021 12:58:00 GMT', modified_at: 'Wed, 03 Mar 2021 18:58:00 GMT' }.to_json }
  let(:druid) { 'druid:bc123df4567' }

  let(:model) do
    Cocina::Models::DRO.new(externalIdentifier: druid,
                            type: Cocina::Models::Vocab.object,
                            label: 'my repository object',
                            version: 1,
                            access: {},
                            administrative: { hasAdminPolicy: 'druid:xx999xx9999' })
  end

  let(:result) { Success(double) }
  let(:indexer) { instance_double(Indexer, reindex_pid: true) }

  before do
    allow(Indexer).to receive(:new).and_return(indexer)
  end

  it 'updates the druid' do
    described_class.new.work(message)
    expect(indexer).to have_received(:reindex_pid)
      .with(add_attributes: { commitWithin: 1000 }, cocina_with_metadata: Success(Array))
  end
end
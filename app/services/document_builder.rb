# frozen_string_literal: true

require 'dry/monads/maybe'

class DocumentBuilder
  ADMIN_POLICY_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RoleMetadataIndexer,
    DefaultObjectRightsIndexer,
    IdentityMetadataIndexer,
    DescriptiveMetadataIndexer,
    IdentifiableIndexer,
    WorkflowsIndexer
  )

  COLLECTION_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataIndexer,
    IdentityMetadataIndexer,
    DescriptiveMetadataIndexer,
    IdentifiableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  ITEM_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataIndexer,
    IdentityMetadataIndexer,
    DescriptiveMetadataIndexer,
    EmbargoMetadataIndexer,
    ContentMetadataIndexer,
    IdentifiableIndexer,
    CollectionTitleIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  SET_INDEXER = CompositeIndexer.new(
    AdministrativeTagIndexer,
    DataIndexer,
    RightsMetadataIndexer,
    IdentityMetadataIndexer,
    DescriptiveMetadataIndexer,
    IdentifiableIndexer,
    WorkflowsIndexer
  )

  INDEXERS = {
    Cocina::Models::Vocab.agreement => ITEM_INDEXER, # Agreement uses same indexer as item
    Cocina::Models::Vocab.admin_policy => ADMIN_POLICY_INDEXER,
    Cocina::Models::Vocab.collection => COLLECTION_INDEXER
  }.freeze

  # @param [Cocina::Models::DRO,Cocina::Models::Collection,Cocina::Model::AdminPolicy] model
  # @param [Hash<String,String>] metadata this contains the updated and created dates
  def self.for(model:, metadata:)
    id = model.externalIdentifier
    Rails.logger.debug { "Fetching indexer for #{model.type}" }
    indexer_for_type(model.type).new(id: id,
                                     cocina: model,
                                     parent_collections: load_parent_collections(model),
                                     administrative_tags: administrative_tags(id),
                                     metadata: metadata)
  end

  def self.indexer_for_type(type)
    INDEXERS.fetch(type, ITEM_INDEXER)
  end

  def self.load_parent_collections(model)
    return [] unless model.dro?

    Array(model.structural.isMemberOf).filter_map do |rel_druid|
      Dor::Services::Client.object(rel_druid).find
    rescue Dor::Services::Client::UnexpectedResponse, Dor::Services::Client::NotFoundResponse
      Honeybadger.notify("Bad association found on #{model.externalIdentifier}. #{rel_druid} could not be found")
      # This may happen if the referenced Collection does not exist (bad data)
      nil
    end
  end

  def self.administrative_tags(id)
    Dor::Services::Client.object(id).administrative_tags.list
  rescue Dor::Services::Client::NotFoundResponse
    []
  end
end

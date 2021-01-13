# frozen_string_literal: true

class Indexer
  ADMIN_POLICY_INDEXER = CompositeIndexer.new(
    DataQualityIndexer,
    AdministrativeTagIndexer,
    DataIndexer,
    RoleMetadataDatastreamIndexer,
    AdministrativeMetadataDatastreamIndexer,
    DefaultObjectRightsDatastreamIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    WorkflowsIndexer
  )

  COLLECTION_INDEXER = CompositeIndexer.new(
    DataQualityIndexer,
    AdministrativeTagIndexer,
    DataIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  ITEM_INDEXER = CompositeIndexer.new(
    DataQualityIndexer,
    AdministrativeTagIndexer,
    DataIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    EmbargoMetadataDatastreamIndexer,
    ContentMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    ReleasableIndexer,
    WorkflowsIndexer
  )

  SET_INDEXER = CompositeIndexer.new(
    DataQualityIndexer,
    AdministrativeTagIndexer,
    DataIndexer,
    ProvenanceMetadataDatastreamIndexer,
    RightsMetadataDatastreamIndexer,
    VersionMetadataDatastreamIndexer,
    ObjectProfileIndexer,
    IdentityMetadataDatastreamIndexer,
    DescriptiveMetadataDatastreamIndexer,
    DescribableIndexer,
    IdentifiableIndexer,
    ProcessableIndexer,
    WorkflowsIndexer
  )

  INDEXERS = {
    Dor::Agreement => ITEM_INDEXER, # Agreement uses same indexer as Dor::Item
    Dor::AdminPolicyObject => ADMIN_POLICY_INDEXER,
    Dor::Collection => COLLECTION_INDEXER,
    Hydrus::Item => ITEM_INDEXER,
    Hydrus::AdminPolicyObject => ADMIN_POLICY_INDEXER,
    Dor::Item => ITEM_INDEXER,
    Dor::Set => SET_INDEXER
  }.freeze

  # @param [Dor::Abstract] obj
  # @param [Dry::Monads::Result] cocina
  def self.for(obj, cocina:)
    Rails.logger.debug("Fetching indexer for #{obj.class}")
    INDEXERS.fetch(obj.class).new(resource: obj, cocina: cocina)
  end
end

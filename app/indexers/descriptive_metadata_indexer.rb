# frozen_string_literal: true

class DescriptiveMetadataIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for descMetadata
  # TODO: Naomi will be writing issues that get correct mapping from Arcadia, that
  #   accommodate structured and parallel values and
  #   any other cocina wrinkles, as well as ensuring the logic follows what SearchWorks uses, conceptually
  def to_solr
    {
      'originInfo_date_created_tesim' => creation&.date&.map(&:value),
      'originInfo_publisher_tesim' => publisher_name,
      'originInfo_place_placeTerm_tesim' => publication&.location&.map(&:value),
      'topic_ssim' => topics,
      'topic_tesim' => topics
    }
  end

  private

  def publisher_name
    publisher = Array(publication&.contributor).find { |contributor| contributor.role.any? { |role| role.value == 'publisher' } }
    Array(publisher&.name).map(&:value)
  end

  def publication
    @publication ||= events.find { |event| event.type == 'publication' }
  end

  def creation
    events.find { |event| event.type == 'creation' }
  end

  def topics
    @topics ||= Array(cocina.description.subject).select { |subject| subject.type == 'topic' }.map(&:value)
  end

  def events
    @events ||= Array(cocina.description.event)
  end
end

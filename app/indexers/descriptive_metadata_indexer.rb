# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class DescriptiveMetadataIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for descriptive metadata
  def to_solr
    {
      'sw_language_ssim' => language,
      'mods_typeOfResource_ssim' => resource_type,
      'sw_format_ssim' => sw_format,
      'sw_genre_ssim' => display_genre,
      'sw_author_tesim' => author,
      'sw_display_title_tesim' => title,
      'sw_subject_temporal_ssim' => subject_temporal,
      'sw_subject_geographic_ssim' => subject_geographic,
      'sw_pub_date_facet_ssi' => ParseDate.earliest_year(pub_date).to_s,
      'originInfo_date_created_tesim' => creation&.date&.map(&:value),
      'originInfo_publisher_tesim' => publisher_name,
      'originInfo_place_placeTerm_tesim' => publication_location,
      'topic_ssim' => topics,
      'topic_tesim' => topics,
      'metadata_format_ssim' => 'mods' # NOTE: seriously? for cocina????
    }.select { |_k, v| v.present? }
  end

  private

  def language
    LanguageBuilder.build(Array(cocina.description.language))
  end

  def subject_temporal
    subjects.flat_map do |subject|
      Array(subject.structuredValue).select { |node| node.type == 'time' }.map(&:value)
    end
  end

  def subject_geographic
    subjects.flat_map do |subject|
      Array(subject.structuredValue).select { |node| node.type == 'place' }.map(&:value)
    end
  end

  def subjects
    @subjects ||= Array(cocina.description.subject)
  end

  def author
    AuthorBuilder.build(Array(cocina.description.contributor))
  end

  def title
    TitleBuilder.build(cocina.description.title)
  end

  def forms
    @forms ||= Array(cocina.description.form)
  end

  def resource_type
    @resource_type ||= forms.select { |form| form.type == 'resource type' }.map(&:value)
  end

  def display_genre
    return [] unless genres

    val = genres.map(&:to_s)
    val << 'Thesis/Dissertation' if (genres & %w[thesis Thesis]).any?
    val << 'Conference proceedings' if (genres & ['conference publication', 'Conference publication', 'Conference Publication']).any?
    val << 'Government document' if (genres & ['government publication', 'Government publication', 'Government Publication']).any?
    val << 'Technical report' if (genres & ['technical report', 'Technical report', 'Technical Report']).any?

    val.uniq
  end

  def genres
    @genres ||= forms.select { |form| form.type == 'genre' }.map(&:value)
  end

  FORMAT = {
    'cartographic' => 'Map',
    'mixed material' => 'Archive/Manuscript',
    'moving image' => 'Video',
    'notated music' => 'Music score',
    'software, multimedia' => 'Software/Multimedia',
    'sound recording-musical' => 'Music recording',
    'sound recording-nonmusical' => 'Sound recording',
    'sound recording' => 'Sound recording',
    'still image' => 'Image',
    'three dimensional object' => 'Object'
  }.freeze

  def sw_format
    FORMAT.fetch(resource_type.first) { sw_format_for_text }
  end

  def archived_website?
    genres.include?('archived website')
  end

  # TODO: part of https://github.com/sul-dlss/dor_indexing_app/issues/567
  # From Arcadia, it should be:
  #  typeOfResource is "text" and any of: issuance is "continuing", issuance is "serial", frequency has a value
  def periodical?
    event_selector('publication')&.note&.any? { |note| note.type == 'issuance' && note.value == 'serial' }
  end

  def pub_date
    PubDateBuilder.build(event_selector('publication'), 'publication') ||
      PubDateBuilder.build(event_selector('creation'), 'creation')
  end

  def sw_format_for_text
    return 'Archived website' if archived_website?
    return 'Journal/Periodical' if periodical?

    'Book'
  end

  def publisher_name
    publisher = Array(publication&.contributor).find { |contributor| contributor.role.any? { |role| role.value == 'publisher' } }
    Array(publisher&.name).map(&:value)&.compact
  end

  def publication
    @publication ||= events.find { |event| event.type == 'publication' }
  end

  def publication_location
    publication&.location&.map(&:value)&.compact
  end

  def creation
    events.find { |event| event.type == 'creation' }
  end

  def topics
    @topics ||= Array(cocina.description.subject).select { |subject| subject.type == 'topic' }.map(&:value).compact
  end

  def events
    @events ||= Array(cocina.description.event).compact
  end

  # NOTE: shameless green to fix production bug.  Ripe for refactor
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def event_selector(date_type)
    # look for event with date of type date_type and of status primary
    pub_event = Array(cocina.description.event&.compact).find do |event|
      event_dates = Array(event.date) + Array(event.parallelEvent&.map(&:date))
      event_dates.flatten.compact.find do |date|
        next if date.type != date_type

        structured_primary = Array(date.structuredValue).find do |structured_date|
          structured_date.status == 'primary'
        end
        date.status == 'primary' || structured_primary
      end
    end
    return pub_event if pub_event.present?

    # otherwise look for event with date of type publication and the event has type publication
    pub_event = Array(cocina.description.event&.compact).find do |event|
      next unless event.type == date_type || event.parallelEvent&.find { |parallel_event| parallel_event.type == date_type }

      event_dates = Array(event.date) + Array(event.parallelEvent&.map(&:date))
      event_dates.flatten.compact.find do |date|
        date.type == date_type
      end
    end
    return pub_event if pub_event.present?

    # otherwise look for event with date of type publication
    Array(cocina.description.event&.compact).find do |event|
      event_dates = Array(event.date) + Array(event.parallelEvent&.map(&:date))
      event_dates.flatten.compact.find do |date|
        date.type == date_type
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
end
# rubocop:enable Metrics/ClassLength

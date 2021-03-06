# frozen_string_literal: true

class ContentMetadataIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for contentMetadata
  def to_solr
    {
      'content_type_ssim' => type(cocina.type),
      'content_file_mimetypes_ssim' => files.map(&:hasMimeType).uniq,
      'content_file_count_itsi' => files.size,
      'shelved_content_file_count_itsi' => shelved_files.size,
      'resource_count_itsi' => file_sets.size,
      'preserved_size_dbtsi' => preserved_files.sum(&:size), # double (trie) to support very large sizes
      'content_file_roles_ssim' => files.map(&:use).compact,
      # first_shelved_image is neither indexed nor multiple
      'first_shelved_image_ss' => first_shelved_image
    }
  end

  private

  def first_shelved_image
    shelved_files.find { |file| file.filename.end_with?('jp2') }&.filename
  end

  def shelved_files
    files.select { |file| file.administrative.shelve }
  end

  def preserved_files
    files.select { |file| file.administrative.sdrPreserve }
  end

  def files
    @files ||= file_sets.flat_map { |fs| fs.structural.contains }
  end

  def file_sets
    @file_sets ||= Array(cocina.structural.contains)
  end

  def type(object_type)
    case object_type
    when Cocina::Models::Vocab.image, Cocina::Models::Vocab.manuscript
      'image'
    when Cocina::Models::Vocab.book
      'book'
    when Cocina::Models::Vocab.map
      'map'
    when Cocina::Models::Vocab.three_dimensional
      '3d'
    when Cocina::Models::Vocab.media
      'media'
    when Cocina::Models::Vocab.webarchive_seed
      'webarchive-seed'
    when Cocina::Models::Vocab.geo
      'geo'
    when Cocina::Models::Vocab.document
      'document'
    else
      'file'
    end
  end
end

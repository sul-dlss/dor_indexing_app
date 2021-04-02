# frozen_string_literal: true

class RightsMetadataIndexer
  attr_reader :resource

  def initialize(resource:, **)
    @resource = resource
  end

  # @return [Hash] the partial solr document for rightsMetadata
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def to_solr
    Rails.logger.debug "In #{self.class}"

    solr_doc = {
      'copyright_ssim' => resource.rightsMetadata.copyright,
      'use_statement_ssim' => resource.rightsMetadata.use_statement
    }

    dra = resource.rightsMetadata.dra_object

    solr_doc['rights_descriptions_ssim'] = [
      dra.index_elements[:primary],

      (dra.index_elements[:obj_locations_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "location: #{rights_info[:location]}#{rule_suffix}"
      end,
      (dra.index_elements[:file_locations_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "location: #{rights_info[:location]} (file)#{rule_suffix}"
      end,

      (dra.index_elements[:obj_groups_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "#{rights_info[:group]}#{rule_suffix}"
      end,
      (dra.index_elements[:file_groups_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "#{rights_info[:group]} (file)#{rule_suffix}"
      end,

      (dra.index_elements[:obj_world_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "world#{rule_suffix}"
      end,
      (dra.index_elements[:file_world_qualified] || []).map do |rights_info|
        rule_suffix = rights_info[:rule] ? " (#{rights_info[:rule]})" : ''
        "world (file)#{rule_suffix}"
      end
    ].flatten.uniq

    # these two values are returned by index_elements[:primary], but are just a less granular version of
    # what the other more specific fields return, so discard them
    solr_doc['rights_descriptions_ssim'] -= %w[access_restricted access_restricted_qualified world_qualified]
    solr_doc['rights_descriptions_ssim'] += ['dark (file)'] if dra.index_elements[:terms].include? 'none_read_file'
    if dra.index_elements[:primary].include? 'cdl_none'
      solr_doc['rights_descriptions_ssim'] += ['controlled digital lending']
      solr_doc['rights_descriptions_ssim'] -= ['cdl_none']
    end

    # suppress empties
    %w[use_statement_ssim copyright_ssim].each do |key|
      solr_doc[key] = solr_doc[key].reject(&:blank?).flatten unless solr_doc[key].nil?
    end

    solr_doc['use_license_machine_ssi'] = resource.rightsMetadata.use_license.first

    solr_doc
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
end
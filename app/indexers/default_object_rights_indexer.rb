# frozen_string_literal: true

class DefaultObjectRightsIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for defaultObjectRights
  def to_solr
    return {} unless cocina.administrative.defaultAccess

    {
      'use_statement_ssim' => use_statement,
      'copyright_ssim' => copyright
    }
  end

  private

  def use_statement
    cocina.administrative.defaultAccess.useAndReproductionStatement
  end

  def copyright
    cocina.administrative.defaultAccess.copyright
  end
end

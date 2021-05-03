# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RightsMetadataIndexer do
  subject(:doc) { indexer.to_solr }

  let(:license) { 'https://creativecommons.org/publicdomain/zero/1.0/' }
  let(:indexer) do
    described_class.new(cocina: cocina)
  end

  context 'with a collection' do
    let(:access) do
      {
        'access' => 'world',
        'license' => license,
        'copyright' => 'Copyright © World Trade Organization',
        'useAndReproductionStatement' => 'Official WTO documents are free for public use.'
      }
    end
    let(:cocina) do
      Cocina::Models.build(
        'externalIdentifier' => 'druid:rt923jk3429',
        'type' => Cocina::Models::Vocab.collection,
        'version' => 1,
        'label' => 'testing',
        'access' => access,
        'administrative' => {
          'hasAdminPolicy' => 'druid:xx000xx0000'
        },
        'description' => {
          'title' => [{ 'value' => 'Test obj' }]
        }
      )
    end

    it 'has the fields used by argo' do
      expect(doc).to include(
        'copyright_ssim' => 'Copyright © World Trade Organization',
        'use_statement_ssim' => 'Official WTO documents are free for public use.',
        'use_license_machine_ssi' => 'CC0-1.0',
        'rights_descriptions_ssim' => 'world'
      )
    end
  end

  context 'with an item' do
    let(:cocina) do
      Cocina::Models.build(
        'externalIdentifier' => 'druid:rt923jk3429',
        'type' => Cocina::Models::Vocab.image,
        'version' => 1,
        'label' => 'testing',
        'access' => access,
        'administrative' => {
          'hasAdminPolicy' => 'druid:xx000xx0000'
        },
        'description' => {
          'title' => [{ 'value' => 'Test obj' }]
        },
        'structural' => structural
      )
    end
    let(:structural) { {} }
    let(:access) do
      {
        'access' => 'world',
        'download' => 'world',
        'license' => license,
        'copyright' => 'Copyright © World Trade Organization',
        'useAndReproductionStatement' => 'Official WTO documents are free for public use.'
      }
    end

    it 'has the fields used by argo' do
      expect(doc).to include(
        'copyright_ssim' => 'Copyright © World Trade Organization',
        'use_statement_ssim' => 'Official WTO documents are free for public use.',
        'use_license_machine_ssi' => 'CC0-1.0',
        'rights_descriptions_ssim' => ['world']
      )
    end

    describe 'rights descriptions' do
      subject { doc['rights_descriptions_ssim'] }

      let(:structural) do
        {
          "contains": [
            {
              "type": 'http://cocina.sul.stanford.edu/models/resources/page.jsonld',
              "externalIdentifier": 'http://cocina.sul.stanford.edu/fileSet/d906da21-aca1-4b95-b7d1-c14c23cd93e6',
              "label": 'Page 1',
              "version": 5,
              "structural": {
                "contains": [
                  {
                    "type": 'http://cocina.sul.stanford.edu/models/file.jsonld',
                    "externalIdentifier": 'http://cocina.sul.stanford.edu/file/4d88213d-f150-45ae-a58a-08b1045db2a0',
                    "label": '50807230_0001.jp2',
                    "filename": '50807230_0001.jp2',
                    "size": 3_575_822,
                    "version": 5,
                    "hasMimeType": 'image/jp2',
                    "hasMessageDigests": [
                      {
                        "type": 'sha1',
                        "digest": '0a089200032d209e9b3e7f7768dd35323a863fcc'
                      },
                      {
                        "type": 'md5',
                        "digest": 'c99fae3c4c53e40824e710440f08acb9'
                      }
                    ],
                    "access": file_access,
                    "administrative": {
                      "publish": false,
                      "sdrPreserve": false,
                      "shelve": false
                    },
                    "presentation": {}
                  }
                ]
              }
            }
          ]
        }
      end

      context 'when citation only' do
        let(:access) do
          {
            'access' => 'citation-only',
            'download' => 'none'
          }
        end

        let(:file_access) do
          {
            'access' => 'dark',
            'download' => 'none'
          }
        end

        it { is_expected.to eq ['citation'] }
      end

      context 'when controlled digital lending' do
        let(:access) do
          {
            'access' => 'stanford',
            'download' => 'none',
            'controlledDigitalLending' => true
          }
        end

        let(:file_access) do
          {
            'access' => 'stanford',
            'download' => 'none',
            'controlledDigitalLending' => false
          }
        end

        it { is_expected.to eq 'controlled digital lending' }
      end

      context 'when dark' do
        let(:access) do
          {
            'access' => 'dark',
            'download' => 'none'
          }
        end

        let(:file_access) do
          {
            'access' => 'dark',
            'download' => 'none'
          }
        end

        it { is_expected.to eq ['dark'] }
      end

      context 'when location' do
        context 'when downloadable' do
          let(:access) do
            {
              'access' => 'location-based',
              'download' => 'location-based',
              'readLocation' => 'spec'
            }
          end

          let(:file_access) do
            {
              'access' => 'location-based',
              'download' => 'location-based',
              'readLocation' => 'spec'
            }
          end

          it { is_expected.to eq ['location: spec'] }
        end

        context 'when not downloadable' do
          let(:access) do
            {
              'access' => 'location-based',
              'download' => 'none',
              'readLocation' => 'spec'
            }
          end

          let(:file_access) do
            {
              'access' => 'location-based',
              'download' => 'none',
              'readLocation' => 'spec'
            }
          end

          it { is_expected.to eq ['location: spec (no-download)'] }
        end
      end

      context 'when no-download' do
        let(:access) do
          {
            'access' => 'world',
            'download' => 'none'
          }
        end

        let(:file_access) do
          {
            'access' => 'world',
            'download' => 'none'
          }
        end

        it { is_expected.to eq ['world (no-download)'] }
      end

      context 'when stanford, dark (file)' do
        # via https://argo.stanford.edu/view/druid:hz651dj0129
        let(:access) do
          {
            'access' => 'stanford',
            'download' => 'stanford'
          }
        end

        let(:file_access) do
          {
            "access": 'dark',
            "download": 'none'
          }
        end

        it { is_expected.to eq ['stanford', 'dark (file)'] }
      end

      context 'when stanford, world (file)' do
        # Via https://argo.stanford.edu/view/druid:bb142ws0723
        let(:structural) do
          {
            "contains": [
              {
                "type": 'http://cocina.sul.stanford.edu/models/resources/page.jsonld',
                "externalIdentifier": 'http://cocina.sul.stanford.edu/fileSet/d906da21-aca1-4b95-b7d1-c14c23cd93e6',
                "label": 'Page 1',
                "version": 5,
                "structural": {
                  "contains": [
                    {
                      "type": 'http://cocina.sul.stanford.edu/models/file.jsonld',
                      "externalIdentifier": 'http://cocina.sul.stanford.edu/file/4d88213d-f150-45ae-a58a-08b1045db2a0',
                      "label": '50807230_0001.jp2',
                      "filename": '50807230_0001.jp2',
                      "size": 3_575_822,
                      "version": 5,
                      "hasMimeType": 'image/jp2',
                      "hasMessageDigests": [
                        {
                          "type": 'sha1',
                          "digest": '0a089200032d209e9b3e7f7768dd35323a863fcc'
                        },
                        {
                          "type": 'md5',
                          "digest": 'c99fae3c4c53e40824e710440f08acb9'
                        }
                      ],
                      "access": file_access,
                      "administrative": {
                        "publish": false,
                        "sdrPreserve": false,
                        "shelve": false
                      },
                      "presentation": {}
                    }
                  ]
                }
              }
            ]
          }
        end
        let(:access) do
          {
            'access' => 'stanford',
            'download' => 'stanford'
          }
        end

        let(:file_access) do
          {
            "access": 'world',
            "download": 'world'
          }
        end

        it { is_expected.to eq ['stanford', 'world (file)'] }
      end

      context 'when citation, world (file)' do
        # https://argo.stanford.edu/view/druid:mq506jn2183
        let(:structural) do
          {
            "contains": [
              {
                "type": 'http://cocina.sul.stanford.edu/models/resources/page.jsonld',
                "externalIdentifier": 'http://cocina.sul.stanford.edu/fileSet/d906da21-aca1-4b95-b7d1-c14c23cd93e6',
                "label": 'Page 1',
                "version": 5,
                "structural": {
                  "contains": [
                    {
                      "type": 'http://cocina.sul.stanford.edu/models/file.jsonld',
                      "externalIdentifier": 'http://cocina.sul.stanford.edu/file/4d88213d-f150-45ae-a58a-08b1045db2a0',
                      "label": '50807230_0001.jp2',
                      "filename": '50807230_0001.jp2',
                      "size": 3_575_822,
                      "version": 5,
                      "hasMimeType": 'image/jp2',
                      "hasMessageDigests": [
                        {
                          "type": 'sha1',
                          "digest": '0a089200032d209e9b3e7f7768dd35323a863fcc'
                        },
                        {
                          "type": 'md5',
                          "digest": 'c99fae3c4c53e40824e710440f08acb9'
                        }
                      ],
                      "access": file_access,
                      "administrative": {
                        "publish": false,
                        "sdrPreserve": false,
                        "shelve": false
                      },
                      "presentation": {}
                    }
                  ]
                }
              }
            ]
          }
        end

        let(:access) do
          {
            'access' => 'citation-only',
            'download' => 'none'
          }
        end

        let(:file_access) do
          {
            "access": 'world',
            "download": 'world'
          }
        end

        it { is_expected.to eq ['citation', 'world (file)'] }
      end

      context 'when world (no-download), stanford (no-download) (file)' do
        # via https://argo.stanford.edu/view/druid:cb810hh5010
        let(:structural) do
          {
            "contains": [
              {
                "type": 'http://cocina.sul.stanford.edu/models/resources/page.jsonld',
                "externalIdentifier": 'http://cocina.sul.stanford.edu/fileSet/d906da21-aca1-4b95-b7d1-c14c23cd93e6',
                "label": 'Page 1',
                "version": 5,
                "structural": {
                  "contains": [
                    {
                      "type": 'http://cocina.sul.stanford.edu/models/file.jsonld',
                      "externalIdentifier": 'http://cocina.sul.stanford.edu/file/4d88213d-f150-45ae-a58a-08b1045db2a0',
                      "label": '50807230_0001.jp2',
                      "filename": '50807230_0001.jp2',
                      "size": 3_575_822,
                      "version": 5,
                      "hasMimeType": 'image/jp2',
                      "hasMessageDigests": [
                        {
                          "type": 'sha1',
                          "digest": '0a089200032d209e9b3e7f7768dd35323a863fcc'
                        },
                        {
                          "type": 'md5',
                          "digest": 'c99fae3c4c53e40824e710440f08acb9'
                        }
                      ],
                      "access": file_access,
                      "administrative": {
                        "publish": false,
                        "sdrPreserve": false,
                        "shelve": false
                      },
                      "presentation": {}
                    }
                  ]
                }
              }
            ]
          }
        end
        let(:access) do
          {
            'access' => 'world',
            'download' => 'none'
          }
        end

        let(:file_access) do
          {
            "access": 'stanford',
            "download": 'none',
            "controlledDigitalLending": false
          }
        end

        it { is_expected.to eq ['world (no-download)', 'stanford (no-download) (file)'] }
      end

      context 'when two object level access. stanford, world (no-download), and world (file) ' do
        # via https://argo.stanford.edu/view/druid:bd336ff4952
        let(:structural) do
          {
            "contains": [
              {
                "type": 'http://cocina.sul.stanford.edu/models/resources/page.jsonld',
                "externalIdentifier": 'http://cocina.sul.stanford.edu/fileSet/d906da21-aca1-4b95-b7d1-c14c23cd93e6',
                "label": 'Page 1',
                "version": 5,
                "structural": {
                  "contains": [
                    {
                      "type": 'http://cocina.sul.stanford.edu/models/file.jsonld',
                      "externalIdentifier": 'http://cocina.sul.stanford.edu/file/4d88213d-f150-45ae-a58a-08b1045db2a0',
                      "label": '50807230_0001.jp2',
                      "filename": '50807230_0001.jp2',
                      "size": 3_575_822,
                      "version": 5,
                      "hasMimeType": 'image/jp2',
                      "hasMessageDigests": [
                        {
                          "type": 'sha1',
                          "digest": '0a089200032d209e9b3e7f7768dd35323a863fcc'
                        },
                        {
                          "type": 'md5',
                          "digest": 'c99fae3c4c53e40824e710440f08acb9'
                        }
                      ],
                      "access": file_access,
                      "administrative": {
                        "publish": false,
                        "sdrPreserve": false,
                        "shelve": false
                      },
                      "presentation": {}
                    }
                  ]
                }
              }
            ]
          }
        end
        let(:access) do
          {
            'access' => 'world',
            'download' => 'stanford'
          }
        end

        let(:file_access) do
          {
            "access": 'world',
            "download": 'world'
          }
        end

        it { is_expected.to eq ['stanford', 'world (no-download)', 'world (file)'] }
      end
    end
  end
end

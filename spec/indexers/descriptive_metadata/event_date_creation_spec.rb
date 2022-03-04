# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptiveMetadataIndexer do
  subject(:indexer) { described_class.new(cocina: cocina) }

  let(:cocina) { Cocina::Models.build(JSON.parse(json)) }
  let(:doc) { indexer.to_solr }
  let(:json) do
    <<~JSON
      {
        "cocinaVersion": "0.0.1",
        "type": "http://cocina.sul.stanford.edu/models/image.jsonld",
        "externalIdentifier": "druid:qy781dy0220",
        "label": "SUL Logo for forebrain",
        "version": 1,
        "access": {
          "access": "world",
          "copyright": "This work is copyrighted by the creator.",
          "download": "world",
          "useAndReproductionStatement": "This document is available only to the Stanford faculty, staff and student community."
        },
        "administrative": {
          "hasAdminPolicy": "druid:zx485kb6348"
        },
        "description": #{JSON.generate(description.merge(purl: 'https://purl.stanford.edu/qy781dy0220'))},
        "identification": {
          "sourceId": "hydrus:object-6"
        },
        "structural": {
          "contains": [{
            "type": "http://cocina.sul.stanford.edu/models/resources/file.jsonld",
            "externalIdentifier": "qy781dy0220_1",
            "label": "qy781dy0220_1",
            "version": 1,
            "structural": {
              "contains": [{
                "type": "http://cocina.sul.stanford.edu/models/file.jsonld",
                "externalIdentifier": "druid:qy781dy0220/sul-logo.png",
                "label": "sul-logo.png",
                "filename": "sul-logo.png",
                "size": 19823,
                "version": 1,
                "hasMimeType": "image/png",
                "hasMessageDigests": [{
                    "type": "sha1",
                    "digest": "b5f3221455c8994afb85214576bc2905d6b15418"
                  },
                  {
                    "type": "md5",
                    "digest": "7142ce948827c16120cc9e19b05acd49"
                  }
                ],
                "access": {
                  "access": "world",
                  "download": "world"
                },
                "administrative": {
                  "publish": true,
                  "sdrPreserve": true,
                  "shelve": true
                }
              }]
            }
          }],
          "isMemberOf": [
            "druid:nb022qg2431"
          ]
        }
      }
    JSON
  end

  describe 'date mappings from Cocina to Solr originInfo_date_created_tesim' do
    context 'when date.type creation and date.status primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              date: [
                {
                  value: '1900',
                  type: 'creation',
                  status: 'primary'
                }
              ]
            }
          ]
        }
      end

      it 'uses date' do
        expect(doc).to include('originInfo_date_created_tesim' => '1900')
      end
    end

    context 'when one date.type creation and other date type has date.status primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              date: [
                {
                  value: '1900',
                  type: 'creation'
                },
                {
                  value: '1905',
                  type: 'publication',
                  status: 'primary'
                }
              ]
            }
          ]
        }
      end

      it 'uses date.type creation' do
        expect(doc).to include('originInfo_date_created_tesim' => '1900')
      end
    end

    context 'when event.type creation and date.type not creation' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'creation',
              date: [
                {
                  value: '1900',
                  type: 'publication'
                }
              ]
            }
          ]
        }
      end

      it 'does not populate field' do
        expect(doc).not_to include('originInfo_date_created_tesim')
      end
    end

    context 'when multiple date.type creation and no date.status primary' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              date: [
                {
                  value: '1900',
                  type: 'creation'
                }
              ]
            },
            {
              date: [
                {
                  value: '1905',
                  type: 'creation'
                }
              ]
            }
          ]
        }
      end

      it 'uses first date with type creation' do
        expect(doc).to include('originInfo_date_created_tesim' => '1900')
      end
    end

    context 'when no date.type creation and only event.type creation has date with no type' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'creation',
              date: [
                {
                  value: '1900'
                }
              ]
            },
            {
              type: 'publication',
              date: [
                {
                  value: '1905'
                }
              ]
            }

          ]
        }
      end

      it 'uses date from event type creation' do
        expect(doc).to include('originInfo_date_created_tesim' => '1900')
      end
    end

    context 'when event.type not creation has only date.type creation in record' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'publication',
              date: [
                {
                  value: '1900',
                  type: 'creation'
                },
                {
                  value: '1905',
                  type: 'publication'
                }
              ]
            }
          ]
        }
      end

      it 'uses value from date.type creation' do
        expect(doc).to include('originInfo_date_created_tesim' => '1900')
      end
    end

    context 'when no event.type creation and no date.type creation' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'publication',
              date: [
                {
                  value: '1900',
                  type: 'publication',
                  status: 'primary'
                }
              ]
            }
          ]
        }
      end

      it 'does not populate originInfo_date_created_tesim' do
        expect(doc).not_to include('originInfo_date_created_tesim')
      end
    end

    context 'when creation date is range' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'creation',
              date: [
                {
                  structuredValue: [
                    {
                      value: '1900',
                      type: 'start'
                    },
                    {
                      value: '1905',
                      type: 'end'
                    }
                  ],
                  type: 'creation',
                  status: 'primary'
                }
              ]
            }
          ]
        }
      end

      it 'uses the first value in the range' do
        expect(doc).to include('originInfo_date_created_tesim' => '1900')
      end
    end

    context 'when creation date is in parallelValue' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              date: [
                {
                  parallelValue: [
                    {
                      value: '1900-04-02',
                      note: [
                        {
                          value: 'Gregorian',
                          type: 'calendar'
                        }
                      ]
                    },
                    {
                      value: '1900-03-20',
                      note: [
                        {
                          value: 'Julian',
                          type: 'calendar'
                        }
                      ]
                    }
                  ],
                  type: 'creation'
                }
              ]
            }
          ]
        }
      end

      it 'uses the first creation date in parallelValue' do
        expect(doc).to include('originInfo_date_created_tesim' => '1900-04-02')
      end
    end

    context 'when creation date is in parallelEvent' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              type: 'creation',
              parallelEvent: [
                {
                  date: [
                    {
                      value: '1900-04-02',
                      note: [
                        {
                          value: 'Gregorian',
                          type: 'calendar'
                        }
                      ]
                    }
                  ]
                },
                {
                  date: [
                    {
                      value: '1900-03-20',
                      note: [
                        {
                          value: 'Julian',
                          type: 'calendar'
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'uses first creation date in parallelEvent' do
        expect(doc).to include('originInfo_date_created_tesim' => '1900-04-02')
      end
    end
  end
end

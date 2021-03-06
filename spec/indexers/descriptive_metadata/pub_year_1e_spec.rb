# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DescriptiveMetadataIndexer do
  subject(:indexer) { described_class.new(cocina: cocina) }

  let(:cocina) { Cocina::Models.build(JSON.parse(json)) }
  let(:json) do
    <<~JSON
      {
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
      		"hasAdminPolicy": "druid:zx485kb6348",
      		"partOfProject": "H2"
      	},
      	"description": #{JSON.generate(description)},
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
  let(:doc) { indexer.to_solr }

  describe 'publication year mappings from Cocina to Solr sw_pub_date_facet_ssi' do
    # Choose single date from selected event
    context 'when date with status primary' do
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
                  value: '2020',
                  status: 'primary'
                },
                {
                  value: '2019'
                }
              ]
            }
          ]
        }
      end

      it 'selects date with status primary' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when one publication date, no primary' do
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
                  value: '2020',
                  type: 'publication'
                },
                {
                  value: '2019',
                  type: 'creation'
                }
              ]
            }
          ]
        }
      end

      it 'selects date with type publication' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when multiple publication dates, no primary' do
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
                  value: '2020',
                  type: 'publication'
                },
                {
                  value: '2019',
                  type: 'publication'
                }
              ]
            }
          ]
        }
      end

      it 'selects first date with type publication' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when no publication date, single creation date, no primary' do
      # date type creation or production
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
                  value: '2020',
                  type: 'creation'
                },
                {
                  value: '2019'
                }
              ]
            }
          ]
        }
      end

      it 'selects date with type creation or production' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when no publication date, multiple creation dates, no primary' do
      # date type creation or production
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
                  value: '2020',
                  type: 'production'
                },
                {
                  value: '2019',
                  type: 'creation'
                }
              ]
            }
          ]
        }
      end

      it 'selects first date with type creation or production' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when no publication or creation date, single capture date, no primary' do
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
                  value: '2020',
                  type: 'capture'
                },
                {
                  value: '2019'
                }
              ]
            }
          ]
        }
      end

      it 'selects date with type capture' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when no publication or creation date, multiple capture dates, no primary' do
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
                  value: '2020',
                  type: 'capture'
                },
                {
                  value: '2019',
                  type: 'capture'
                }
              ]
            }
          ]
        }
      end

      it 'selects first date with type capture' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when no publication, creation, or capture date, single copyright date, no primary' do
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
                  value: '2020',
                  type: 'copyright'
                },
                {
                  value: '2019'
                }
              ]
            }
          ]
        }
      end

      it 'selects date with type copyright' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when no publication, creation, or capture date, multiple copyright dates, no primary' do
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
                  value: '2020',
                  type: 'copyright'
                },
                {
                  value: '2019',
                  type: 'copyright'
                }
              ]
            }
          ]
        }
      end

      it 'selects first date with type copyright' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when none of the above' do
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
                  value: '2020'
                },
                {
                  value: '2019'
                }
              ]
            }
          ]
        }
      end

      it 'selects first date' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when date range, one primary' do
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
                  structuredValue: [
                    {
                      value: '2020',
                      type: 'start'
                    },
                    {
                      value: '2021',
                      type: 'end',
                      status: 'primary'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects date with status primary' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2021')
      end
    end

    context 'when date range, no primary' do
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
                  structuredValue: [
                    {
                      value: '2020',
                      type: 'start'
                    },
                    {
                      value: '2021',
                      type: 'end'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects first date' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when parallelEvent' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              parallelEvent: [
                {
                  date: [
                    {
                      value: '2021',
                      status: 'primary'
                    }
                  ]
                },
                {
                  date: [
                    {
                      value: '2021年 '
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects date from preferred event' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2021')
      end
    end

    context 'when date range in parallelEvent' do
      let(:description) do
        {
          title: [
            {
              value: 'Title'
            }
          ],
          event: [
            {
              parallelEvent: [
                {
                  date: [
                    {
                      structuredValue: [
                        {
                          value: '2020',
                          type: 'start'
                        },
                        {
                          value: '2021',
                          type: 'end'
                        }
                      ]
                    }
                  ]
                },
                {
                  date: [
                    {
                      structuredValue: [
                        {
                          value: '2020年',
                          type: 'start'
                        },
                        {
                          value: '2021年',
                          type: 'end'
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

      it 'selects preferred date from preferred event' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2020')
      end
    end

    context 'when parallelValue, one primary' do
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
                      value: '2021-04-15',
                      note: [
                        {
                          value: 'Gregorian',
                          type: 'calendar'
                        }
                      ]
                    },
                    {
                      value: '2022-04-02',
                      note: [
                        {
                          value: 'Julian',
                          type: 'calendar'
                        }
                      ],
                      status: 'primary'
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'selects date with status primary' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2022')
      end
    end

    context 'when parallelValue, no primary' do
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
                      value: '2021-04-15',
                      note: [
                        {
                          value: 'Gregorian',
                          type: 'calendar'
                        }
                      ]
                    },
                    {
                      value: '2022-04-02',
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

      it 'selects first date' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2021')
      end
    end

    context 'when date range in parallelValue' do
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
                      structuredValue: [
                        {
                          value: '2021-04-14',
                          type: 'start'
                        },
                        {
                          value: '2022-04-15',
                          type: 'end'
                        }
                      ],
                      note: [
                        {
                          value: 'Gregorian',
                          type: 'calendar'
                        }
                      ]
                    },
                    {
                      structuredValue: [
                        {
                          value: '2023-04-01',
                          type: 'start'
                        },
                        {
                          value: '2024-04-02',
                          type: 'end'
                        }
                      ],
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

      it 'selects preferred date from preferred parallelValue' do
        expect(doc).to include('sw_pub_date_facet_ssi' => '2021')
      end
    end
  end
end

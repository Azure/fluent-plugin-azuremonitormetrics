# fluent-plugin-azuremonitormetric, a plugin for [Fluentd](http://fluentd.org) 
## Overview

***Azure Monitor Metrics*** input plugin.

This plugin gets the monitor metrics from Azure Monitor API to fluentd.

## Installation

Install from RubyGems:
```
$ gem install fluent-plugin-azuremonitormetrics
```

## Configuration

```config
<source>
  @type         azuremonitormetrics
  tag           azuremonitormetrics
  tenant_id     [Azure_Tenant_ID]
  client_id     [Azure_Client_Id]
  client_secret [Azure_Client_Secret]

  timespan          [timespan in second] (default: 300)
  interval          [time grain of the query: string] (default: PT1M)
  resource_uri      [the identifier of the resource]
  aggregation       [list of aggregation types] (example: Average,count)
  top               [Max number of records to retrive]
  orderby           [The aggregation to use for sorting] (example: sum asc)
  filter            [filter to reduce metric data] (example A eq 'a1' and B eq '*')
  result_type       [reduces the set of data collected]
  metric            [The name of the metric to retrive]
  api_version       [api version]   (default: "2017-05-01-preview")
</source>
```

Documentation for all the parameters can found [here](https://docs.microsoft.com/en-us/rest/api/monitor/Metrics/List#get_metric_for_data)\n
This plugin is porting from [fluent-plugin-cloudwatch](https://github.com/yunomu/fluent-plugin-cloudwatch)

#### output data format

```
2017-10-22 14:25:28 azuremonitormetrics {
                                          "cost": 0,
                                          "timespan": "2017-04-14T02:20:00Z/2017-04-14T04:20:00Z",
                                          "interval": "PT1M",
                                          "value": [
                                            {
                                              "id": "/subscriptions/b324c52b-4073-4807-93af-e07d289c093e/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/larryshoebox/blobServices/default/providers/Microsoft.Insights/metrics/BlobCapacity",
                                              "type": "Microsoft.Insights/metrics",
                                              "name": {
                                                "value": "BlobCapacity",
                                                "localizedValue": "Blob Capacity"
                                              },
                                              "unit": "Bytes",
                                              "timeseries": [
                                                {
                                                  "metadatavalues": [
                                                    {
                                                      "name": {
                                                        "value": "blobtype",
                                                        "localizedValue": "blobtype"
                                                      },
                                                      "value": "PageBlob"
                                                    }
                                                  ],
                                                  "data": [
                                                    {
                                                      "timeStamp": "2017-04-14T02:20:00.000Z",
                                                      "count": 0
                                                    },
                                                    {
                                                      "timeStamp": "2017-04-14T02:21:00.000Z",
                                                      "count": 0
                                                    },
                                                    {
                                                      "timeStamp": "2017-04-14T02:22:00.000Z",
                                                      "count": 0
                                                    },
                                                    {
                                                      "timeStamp": "2017-04-14T02:23:00.000Z",
                                                      "count": 1,
                                                      "average": 0
                                                    }
                                                  ]
                                                },
                                                {
                                                  "metadatavalues": [
                                                    {
                                                      "name": {
                                                        "value": "blobtype",
                                                        "localizedValue": "blobtype"
                                                      },
                                                      "value": "BlockBlob"
                                                    }
                                                  ],
                                                  "data": [
                                                    {
                                                      "timeStamp": "2017-04-14T02:20:00.000Z",
                                                      "count": 0
                                                    },
                                                    {
                                                      "timeStamp": "2017-04-14T02:21:00.000Z",
                                                      "count": 0
                                                    },
                                                    {
                                                      "timeStamp": "2017-04-14T02:22:00.000Z",
                                                      "count": 0
                                                    },
                                                    {
                                                      "timeStamp": "2017-04-14T02:23:00.000Z",
                                                      "count": 1,
                                                      "average": 245
                                                    }
                                                  ]
                                                }
                                              ]
                                            }
                                          ]
                                        }
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

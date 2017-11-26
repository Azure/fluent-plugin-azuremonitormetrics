# fluent-plugin-azuremonitormetric, a plugin for [Fluentd](http://fluentd.org) 
## Overview

[Azure Monitor Metrics](https://docs.microsoft.com/en-us/rest/api/monitor/Metrics/List) input plugin.

This plugin gets the monitor metrics from Azure Monitor API to fluentd.

## Installation

To use this plugin, you need to have Azure Service Principal.<br/>
Create an Azure Service Principal through [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json) or [Azure portal](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal).

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
  metrics           [The name of the metrics to retrive, sperated by commas] (example: Network Out,Percentage CPU)
  api_version       [api version]   (default: "2017-05-01-preview")
</source>
```

Documentation for all the parameters can found [here](https://docs.microsoft.com/en-us/rest/api/monitor/Metrics/List#get_metric_for_data)<br/>
This plugin is porting from [fluent-plugin-cloudwatch](https://github.com/yunomu/fluent-plugin-cloudwatch)

Start fluentd:

```
$ fluentd -c ./fluentd.conf
```

#### output data format

Example of Average aggregation on Percentage CPU metric, on timespan of 5 minutes and 1 minute grain:

```
2017-10-22 14:25:28 azuremonitormetrics {
                                          "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my_resource_group/providers/Microsoft.Compute/virtualMachines/my-vm/providers/Microsoft.Insights/metrics/Percentage CPU",
                                          "type": "Microsoft.Insights/metrics",
                                          "name": {
                                            "value": "Percentage CPU",
                                            "localizedValue": "Percentage CPU"
                                          },
                                          "unit": "Percent",
                                          "timeseries": [
                                            {
                                              "metadatavalues": [],
                                              "data": [
                                                {
                                                  "timeStamp": "2017-10-24T14:11:00Z",
                                                  "average": 2.5075
                                                },
                                                {
                                                  "timeStamp": "2017-10-24T14:12:00Z",
                                                  "average": 2.505
                                                },
                                                {
                                                  "timeStamp": "2017-10-24T14:13:00Z",
                                                  "average": 2.455
                                                },
                                                {
                                                  "timeStamp": "2017-10-24T14:14:00Z",
                                                  "average": 2.4375
                                                },
                                                {
                                                  "timeStamp": "2017-10-24T14:15:00Z",
                                                  "average": 2.4375
                                                }
                                              ]
                                            }
                                          ]
                                        }
```

## Test

Run tests:

```
$ rake test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

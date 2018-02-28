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

  timespan          [The query timespan in seconds - must be greater than 60] (default: 300)
  interval          [timegrain of the query] (default: PT1M, allowed values are: PT1M, PT5M, PT15M, PT30M, PT1H, PT6H, PT12H, PT24H)
  resource_uri      [the identifier of the resource]
  aggregation       [list of aggregation types, sperated by commas] (example: Average,count)
  top               [Max number of records to retrive - vaild only if filter is specified. default is 10]
  filter            [filter to reduce metric data] (example A eq 'a1' and B eq '*')
  result_type       [reduces the set of data collected]
  metrics           [The names of the metrics to retrive, sperated by commas] (example: Network Out,Percentage CPU)
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

Example of Average and Count aggregations on Percentage CPU and Network Out metrics, on timespan of 5 minutes and 5 minute grain:

```
2017-10-22 14:25:28 azuremonitormetrics [
   {
      "data":[
         {
            "timeStamp":"2017-11-23T14:30:00Z",
            "count":200.0,
            "average":1115.29
         }
      ],
      "id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myresourcegroup/providers/Microsoft.Compute/virtualMachines/mymachine/providers/Microsoft.Insights/metrics/Network Out",
      "name":{
         "value":"Network Out",
         "localizedValue":"Network Out"
      },
      "type":"Microsoft.Insights/metrics",
      "unit":"Bytes"
   },
   {
      "data":[
         {
            "timeStamp":"2017-11-23T14:30:00Z",
            "count":40.0,
            "average":0.732
         }
      ],
      "id":"/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myresourcegroup/providers/Microsoft.Compute/virtualMachines/mymachine/providers/Microsoft.Insights/metrics/Percentage CPU",
      "name":{
         "value":"Percentage CPU",
         "localizedValue":"Percentage CPU"
      },
      "type":"Microsoft.Insights/metrics",
      "unit":"Percent"
   }
]
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

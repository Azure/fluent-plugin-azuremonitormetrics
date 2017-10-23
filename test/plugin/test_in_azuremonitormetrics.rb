require 'helper'

class AzureMonitorMetricsInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  ### for monitor metrics
  CONFIG_MONITOR_METRICS = %[
    tag azuremonitormetrics
    tenant_id test_tenant_id
    client_id test_client_id
    client_secret test_client_secret

    timespan          300
    interval          PT1M
    resource_uri      /subscriptions/b324c52b-4073-4807-93af-e07d289c093e/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/larryshoebox/blobServices/default/providers/Microsoft.Insights/metrics/BlobCapacity
    aggregation       Average,count
    top               20
    orderby           sum asc
    filter            A eq 'a1' and B eq '*'
    result_type       Success
    metric            Percentage CPU
    api_version      2017-05-01-preview
  ]

  def create_driver_monitor_metrics(conf = CONFIG_MONITOR_METRICS)
    Fluent::Test::InputTestDriver.new(Fluent::AzureMonitorMetricsInput).configure(conf)
  end

  def test_configure_monitor_metrics
    d = create_driver_monitor_metrics
    assert_equal 'azuremonitormetrics', d.instance.tag
    assert_equal 'test_tenant_id', d.instance.tenant_id
    assert_equal 'test_client_id', d.instance.client_id
    assert_equal 300, d.instance.timespan
    assert_equal 'PT1M', d.instance.interval
    assert_equal '/subscriptions/b324c52b-4073-4807-93af-e07d289c093e/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/larryshoebox/blobServices/default/providers/Microsoft.Insights/metrics/BlobCapacity', d.instance.resource_uri
    assert_equal 'Average,count', d.instance.aggregation
    assert_equal 20, d.instance.top
    assert_equal 'sum asc', d.instance.orderby
    assert_equal 'A eq \'a1\' and B eq \'*\'', d.instance.filter
    assert_equal 'Success', d.instance.result_type
    assert_equal 'Percentage CPU', d.instance.metric
    assert_equal '2017-05-01-preview', d.instance.api_version
  end

end

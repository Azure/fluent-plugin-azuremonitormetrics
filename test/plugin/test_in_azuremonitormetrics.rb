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
    aggregation       Average,count
    interval          PT1M
    resource_uri      /subscriptions/b324c52b-4073-4807-93af-e07d289c093e/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/larryshoebox/blobServices/default/providers/Microsoft.Insights/metrics/BlobCapacity
    top               20
    orderby           sum asc
    filter            timeGrain eq duration'PT1M' and (name.value eq 'Network Out' or name.value eq 'Percentage CPU') and (aggregationType eq 'Average' or aggregationType eq 'Count') and startTime eq 2017-10-11T23:00:00Z and endTime eq 2017-11-22T15:00:00Z
    result_type       Success
    api_version       2016-09-01
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
    assert_equal '/subscriptions/b324c52b-4073-4807-93af-e07d289c093e/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/larryshoebox/blobServices/default/providers/Microsoft.Insights/metrics/BlobCapacity', d.instance.resource_uri
    assert_equal 20, d.instance.top
    assert_equal 'sum asc', d.instance.orderby
    assert_equal "timeGrain eq duration'PT1M' and (name.value eq 'Network Out' or name.value eq 'Percentage CPU') and (aggregationType eq 'Average' or aggregationType eq 'Count') and startTime eq 2017-10-11T23:00:00Z and endTime eq 2017-11-22T15:00:00Z", d.instance.filter
    assert_equal 'Success', d.instance.result_type
    assert_equal '2016-09-01', d.instance.api_version
  end

  def test_set_query_options
    d = create_driver_monitor_metrics
    start_time = Time.now - 1000
    end_time = Time.now
    query_options = d.instance.set_path_options(start_time, end_time, {})
    assert_equal '2016-09-01', query_options[:query_params]['api-version']
    assert_equal "timeGrain eq duration'PT1M' and (name.value eq 'Network Out' or name.value eq 'Percentage CPU') and (aggregationType eq 'Average' or aggregationType eq 'Count') and startTime eq #{start_time.utc.iso8601} and endTime eq #{end_time.utc.iso8601}", query_options[:query_params]['$filter']
    assert_equal 20, query_options[:query_params]['$top']
    assert_equal 'sum asc', query_options[:query_params]['$orderby']
    assert_equal 'Success', query_options[:query_params]['resultType']
    assert_equal '/subscriptions/b324c52b-4073-4807-93af-e07d289c093e/resourceGroups/test/providers/Microsoft.Storage/storageAccounts/larryshoebox/blobServices/default/providers/Microsoft.Insights/metrics/BlobCapacity', query_options[:path_params]['resourceUri']
  end

end

require 'fluent/input'
require 'azure_mgmt_monitor'
require 'uri'

class Fluent::AzureMonitorMetricsInput < Fluent::Input
  Fluent::Plugin.register_input("azuremonitormetrics", self)

  # To support log_level option implemented by Fluentd v0.10.43
  unless method_defined?(:log)
    define_method("log") { $log }
  end

  # Define `router` method of v0.12 to support v0.10 or earlier
  unless method_defined?(:router)
    define_method("router") { Fluent::Engine }
  end

  config_param :tag,                :string
  config_param :tenant_id,          :string, :default => nil
  config_param :client_id,          :string, :default => nil
  config_param :client_secret,      :string, :default => nil, :secret => true

  config_param :timespan,           :integer, :default => 300
  config_param :interval,           :string, :default => "PT1M"
  config_param :resource_uri,       :string, :default => nil
  config_param :aggregation,        :string, :default => nil
  config_param :top,                :integer, :default => nil
  config_param :orderby,            :string, :default => nil
  config_param :filter,             :string, :default => nil
  config_param :result_type,        :string, :default => nil
  config_param :metrics,            :string, :default => nil
  config_param :api_version,        :string, :default => "2016-09-01"

  def initialize
    super
  end

  def configure(conf)
    super

    provider = MsRestAzure::ApplicationTokenProvider.new(@tenant_id, @client_id, @client_secret)
    credentials = MsRest::TokenCredentials.new(provider)
    @client = Azure::ARM::Monitor::MonitorManagementClient.new(credentials);
  end

  def start
    super
    @watcher = Thread.new(&method(:watch))
  end

  def shutdown
    super
    @watcher.terminate
    @watcher.join
  end

  def get_param_string(original_param, query_string)
    array = original_param.split(',')
    param_string = ''
    array.each {|var|
      if param_string.empty?
        param_string += "#{query_string} eq '#{var}'"
      else
        param_string += " or #{query_string} eq '#{var}'"
      end
    }

    "and (#{param_string})"

  end

  def set_path_options(start_time, end_time, custom_headers)
    fail ArgumentError, 'start_time is nil' if start_time.nil?
    request_headers = {}

    # Set Headers
    request_headers['x-ms-client-request-id'] = SecureRandom.uuid
    request_headers['accept-language'] = @client.accept_language unless @client.accept_language.nil?

    metrics_string = get_param_string(@metrics, "name.value")
    aggregation_string =  @aggregation.empty? ? '' : get_param_string(@aggregation, "aggregationType")

    filter = "timeGrain eq duration'#{@interval}' #{metrics_string} #{aggregation_string} and startTime eq #{start_time.utc.iso8601} and endTime eq #{end_time.utc.iso8601}"
    log.debug filter
    {
        middlewares: [[MsRest::RetryPolicyMiddleware, times: 3, retry: 0.02], [:cookie_jar]],
        path_params: {'resourceUri' => @resource_uri},
        query_params: {'api-version' => @api_version,
                       '$top' => @top,
                       '$orderby' => @orderby,
                       '$filter' => filter,
                       'resultType' => @result_type},
        headers: request_headers.merge(custom_headers || {}),
        base_url: @client.base_url
    }
  end

  private

  def watch
    log.debug "azure monitor metrics: watch thread starting"
    @next_fetch_time = Time.now

    until @finished
        start_time = @next_fetch_time - @timespan
        end_time = @next_fetch_time

        log.debug "start time: #{start_time}, end time: #{end_time}"


        monitor_metrics_promise = get_monitor_metrics_async(start_time, end_time)
        monitor_metrics = monitor_metrics_promise.value!

        router.emit(@tag, Time.now.to_i, monitor_metrics.body['value'])
        @next_fetch_time += @timespan
        sleep @timespan
    end

  end

  def get_monitor_metrics_async(start_time, end_time,filter = nil, custom_headers = nil)
    path_template = '/{resourceUri}/providers/microsoft.insights/metrics'

    options = set_path_options(start_time, end_time, custom_headers)
    promise = @client.make_request_async(:get, path_template, options)

    promise = promise.then do |result|
      http_response = result.response
      status_code = http_response.status
      response_content = http_response.body
      unless status_code == 200
        error_model = JSON.load(response_content)
        log.error(error_model['error']['message'])
      end

      result.request_id = http_response['x-ms-request-id'] unless http_response['x-ms-request-id'].nil?
      # Deserialize Response
      if status_code == 200
        begin
          result.body = response_content.to_s.empty? ? nil : JSON.load(response_content)
        rescue Exception => e
          log.error("Error occurred in parsing the response")
        end
      end

      result
    end

    promise.execute
  end
end

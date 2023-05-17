# frozen_string_literal: true

module Cukewrapper
  # I process data >:^)
  class RapidAPIExecutor < Executor
    priority :normal

    def run(context)
      return unless @enabled

      client = CukewrapperRapidAPI::Client.new @config
      test = CukewrapperRapidAPI::RapidAPITest.new client, @test_id
      LOGGER.debug("#{self.class.name}##{__method__}") { 'Executing test' }
      @testexecution, report_url = test.execute(req_params, req_body(context['data'] || {}))
      Cukewrapper::Runtime.world.log("Full Report: #{report_url}")
    end

    def register_hooks
      Hooks.register("#{self.class.name}:enable", :after_metatags, &enable)
      Hooks.register("#{self.class.name}:check_result", :after_scenario, &check_result)
    end

    private

    def enable
      lambda do |_context, metatags|
        @config = CONFIG['rapidapi'] || {}
        @metatags = metatags['rapid'] || {}
        @test_id = "test_#{@metatags['tid']}"
        @enabled = !@metatags['tid'].nil?
        LOGGER.debug("#{self.class.name}##{__method__}") { @enabled }
      end
    end

    def check_status
      LOGGER.debug("#{self.class.name}##{__method__}") { 'Checking status' }
      @testexecution.status
    end

    def check_result
      lambda do |_context, _scenario|
        return unless @enabled

        wait_time = 10
        while (status = check_status) && status['status'] != 'complete' && status['status'] != 'failed to start'
          LOGGER.debug("#{self.class.name}##{__method__}") do
            "Current status is #{status['status']}, sleeping #{wait_time} seconds"
          end
          sleep wait_time
        end

        raise 'Test unable to start' if status['status'] == 'failed to start'

        report_failure unless status['successful']
      end
    end

    def report_failure
      report = JSON.parse(@testexecution.details['report'])[0]
      variable_overrides = @testexecution.details['variableOverrides']

      Cukewrapper::Runtime.world.log("Summary: #{report['shortSummary']}")
      unless variable_overrides.nil?
        Cukewrapper::Runtime.world.log("Variable Overrides: #{JSON.pretty_generate(variable_overrides)}")
      end

      raise 'Failure when executing test'
    end

    def req_params
      { 'source' => 'trigger', 'environment' => @config['environment'] }
        .compact
        .merge(@config.slice('context', 'location'))
    end

    def req_body(payload)
      { 'baseContext' => base_context(payload) }
    end

    def base_context(payload)
      payload.transform_values do |value|
        case value
        when Hash, Array
          value.to_json
        when Integer, Float, TrueClass, FalseClass, String
          value
        when NilClass
          'null'
        else
          value.to_s
        end
      end
    end
  end
end

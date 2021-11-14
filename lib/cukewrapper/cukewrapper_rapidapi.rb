# frozen_string_literal: true

module Cukewrapper
  # I process data >:^)
  class RapidAPIExecutor < Executor
    priority :normal

    def run(context)
      return unless @enabled

      test = CukewrapperRapidAPI::RapidAPITest.new @test_id
      LOGGER.debug("#{self.class.name}\##{__method__}") { 'Executing test' }
      @testexecution = test.execute(req_params, req_body(context['data'] || {}))
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
        LOGGER.debug("#{self.class.name}\##{__method__}") { @enabled }
      end
    end

    def check_status
      LOGGER.debug("#{self.class.name}\##{__method__}") { 'Checking status' }
      @testexecution.status
    end

    def check_result
      lambda do |_context, _scenario|
        return unless @enabled

        wait_time = 1
        while (status = check_status) && status['status'] != 'complete'
          LOGGER.debug("#{self.class.name}\##{__method__}") { "Sleeping #{wait_time} seconds" }
          sleep wait_time
          wait_time *= 2
        end

        raise "Failure when executing test: #{status}" unless status['successful']
      end
    end

    def environment
      ENV['RAPIDAPI_ENV'] || @config['environment'] || nil
    end

    def req_params
      { 'source' => 'trigger', 'environment' => environment }
        .compact
        .merge(@config.slice('context', 'location'))
    end

    def req_body(payload)
      { 'baseContext' => base_context(payload) }
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def base_context(payload)
      payload.transform_values do |value|
        case value
        when Hash || Array
          value.to_json
        when Integer || Float || TrueClass || FalseClass || String
          value
        when NilClass
          'null'
        else
          value.to_s
        end
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end

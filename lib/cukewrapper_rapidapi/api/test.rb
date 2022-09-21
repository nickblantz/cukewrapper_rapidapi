# frozen_string_literal: true

module CukewrapperRapidAPI
  # Wraps the test trigger API
  class RapidAPITest
    def initialize(client, test_id)
      @client = client
      options = 
      response = @client.get "/test/#{test_id}", {
        query: { 'test' => test_id }
      }
      raise "Error getting test: #{response.code} | #{response.body}" unless response.code == 200
      
      @internal = response.parsed_response
    end

    def execute(query, body)
      response = @client.post("/trigger/test/#{@internal['id']}/execute", {
        body: body.to_json,
        query: query
      })

      raise "Error executing test: #{response.code} | #{response.body}" unless response.code == 201

      RapidAPITestExecution.new(@client, @internal['id'], response.parsed_response['executionId'])
    end
  end
end

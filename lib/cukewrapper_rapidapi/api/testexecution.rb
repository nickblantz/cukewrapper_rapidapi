# frozen_string_literal: true

module CukewrapperRapidAPI
  # Wraps the test execution API
  class RapidAPITestExecution
    def initialize(client, test_id, testexecution_id)
      @client = client
      @test_id = test_id
      @testexecution_id = testexecution_id
    end

    def status
      response = @client.get("/trigger/execution/#{@testexecution_id}/status")
      raise "Error checking testexcecution status: #{response.code} | #{response.body}" unless response.code == 200

      response.parsed_response
    end

    def details
      response = @client.get("/test/#{@test_id}/execution/#{@testexecution_id}?include=environment&include=test/trigger/execution/")
      raise "Error checking testexcecution details: #{response.code} | #{response.body}" unless response.code == 200

      response.parsed_response
    end
  end
end

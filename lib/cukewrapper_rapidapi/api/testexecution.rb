# frozen_string_literal: true

module CukewrapperRapidAPI
  # Wraps the test execution API
  class RapidAPITestExecution
    include HTTParty
    base_uri 'https://rapidapi.com/testing/api'

    HEADERS = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }.freeze

    def initialize(testexecution_id)
      @testexecution_id = testexecution_id
    end

    def status
      options = { headers: HEADERS }
      response = self.class.get("/trigger/execution/#{@testexecution_id}/status", options)
      raise "Error checking testexcecution status: #{response.code} | #{response.body}" unless response.code == 200

      JSON.parse(response.body)
    end
  end
end

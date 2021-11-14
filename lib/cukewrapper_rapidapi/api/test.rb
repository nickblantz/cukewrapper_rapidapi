# frozen_string_literal: true

module CukewrapperRapidAPI
  # Wraps the test trigger API
  class RapidAPITest
    include HTTParty
    base_uri 'https://rapidapi.com/testing/api'

    HEADERS = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'x-jwt_auth' => CukewrapperRapidAPI::SESSION.token
    }.freeze

    def initialize(test_id)
      options = { query: { 'test' => test_id }, headers: HEADERS }
      response = self.class.get("/test/#{test_id}", options)
      raise "Error getting test: #{response.code} | #{response.body}" unless response.code == 200

      @internal = JSON.parse(response.body)
    end

    def execute(query, body)
      options = { body: body.to_json, query: query, headers: HEADERS }
      response = self.class.post("/trigger/test/#{@internal['id']}/execute", options)
      raise "Error executing test: #{response.code} | #{response.body}" unless response.code == 201

      RapidAPITestExecution.new(JSON.parse(response.body)['executionId'])
    end
  end
end

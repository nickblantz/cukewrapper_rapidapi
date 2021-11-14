# frozen_string_literal: true

# Internals for executing RapidAPI tests
module CukewrapperRapidAPI
  # Wraps the test execution API
  class RapidAPISession
    include HTTParty
    base_uri 'https://rapidapi.com/testing/api'

    HEADERS = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }.freeze

    attr_reader :token

    def initialize(auth)
      options = { body: auth.to_json, headers: HEADERS }
      response = self.class.post('/jwt', options)
      raise "Error authenticating: #{response.code} | #{response.body}" unless response.code == 200

      @token = JSON.parse(response.body)['token']
    end
  end

  def self.__rapidapi_auth
    username = ENV['RAPIDAPI_USERNAME']
    password = ENV['RAPIDAPI_PASSWORD']
    { 'username' => username, 'password' => password }
  end

  SESSION = RapidAPISession.new(__rapidapi_auth)
end

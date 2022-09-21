# frozen_string_literal: true

module CukewrapperRapidAPI
  class Client
    include HTTParty
    format :json

    def initialize(config)
      self.class.base_uri(config.fetch('base_uri', default_config['base_uri']))
      @auth_token = get_auth_token
    end

    def get(path, options = {})
      options = default_options.merge(options)
      self.class.get path, options
    end

    def post(path, options = {})
      options = default_options.merge(options)
      self.class.post path, options
    end

    private

    def get_auth_token
      response = post '/token', {
        body: auth_config.to_json,
        headers: {
          'Accept' => 'text/plain',
          'Content-Type' => 'application/json',
        }
      }

      raise "Error getting auth token: #{response.code} | #{response.body}" unless response.code == 200

      response.parsed_response
    end

    def default_config
      {
        'base_uri' => 'https://rapidapi.com/testing/api',
      }.freeze
    end

    def default_options
      {
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Cookie' => auth_cookie,
        }
      }
    end

    def auth_config
      username = ENV['RAPIDAPI_USERNAME']
      password = ENV['RAPIDAPI_PASSWORD']
      { 'username' => username, 'password' => password }
    end

    def auth_cookie
      return "" if @auth_token.nil?

      "#{@auth_token['name']}=#{@auth_token['value']}"
    end
  end
end
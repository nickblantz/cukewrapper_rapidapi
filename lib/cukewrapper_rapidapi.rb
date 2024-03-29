# frozen_string_literal: true

# Internals for executing RapidAPI tests
# https://rapidapi.com/testing/api/docs/
module CukewrapperRapidAPI
  require 'json'
  require 'httparty'
  require 'cukewrapper_rapidapi/client'
  require 'cukewrapper_rapidapi/api/test'
  require 'cukewrapper_rapidapi/api/testexecution'
  require 'cukewrapper/cukewrapper_rapidapi'
end

require 'uri'
require 'coral/handler'
require 'coral/log_factory'
require 'coral/support/logging'

module Coral

  # Attaches the specified endpoint URI to the outgoing request.
  class HttpDestinationHandler < Handler
    include Coral::Support::Logging

    # Initialize an HttpDestinationHandler with the specified endpoint URI.
    def initialize(endpoint)
      @uri = endpoint.is_a?(URI) ? endpoint : URI.parse(endpoint)
      @uri.path = '/' if @uri.path.nil? || @uri.path.empty?
    end

    def before(job)
      job.request[:http_verb] = 'GET'
      job.request[:http_uri] = @uri.clone

      logger.debug "Initial request URI #{@uri}"
    end
  end

end

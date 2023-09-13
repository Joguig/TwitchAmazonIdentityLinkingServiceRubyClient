require 'coral/support/uuid'
require 'coral/client_timeout'
require 'coral/client_error'
require 'coral/unknown_exception'

module Coral

  # Contains context pertaining to a specific request to a remote service.
  class Call
    # the request ID to attach to the outgoing request. (Internal only)
    attr_accessor :request_id

    # The hash of identity information for the outgoing request.
    # The identity is mutable such that callers may add or remove identity information from it.
    attr_accessor :identity

    # Create a new Call object tied to a specific Dispatcher.
    # The service parameter must be a Coral::Service, and the operation_name should be a model id string.
    def initialize(service, operation_name)
      @service = service
      @operation_name = operation_name

      @identity = {}
      @request_id = nil
    end

    # Invoke the remote service and return the result.
    # The input must be a Coral::Structure.
    def call(input = nil)
      @request_id ||= Coral::Support::UUID.random_create

      request = {
        :operation_name => @operation_name,
        :service_name => @service.class.model_id.to_s,
        :identity => identity,
        :id => request_id,
        :value => input
      }

      begin
        reply = @service.orchestrator.orchestrate(request)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => timeout
        raise Coral::ClientTimeout.new("Timeout", timeout)
      rescue ::Exception => e
        raise Coral::ClientError.new(e.message, e)
      end

      value = reply[:value]

      # If the object we recieved from the service was an Exception, raise it from here.
      if value.is_a?(Coral::Exception)
        raise value
      end

      return value
    end

  end
end

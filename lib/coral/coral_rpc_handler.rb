require 'coral/handler'
require 'coral/coral_rpc_translator'
require 'coral/support/logging'
require 'coral/support/json_helper'

module Coral
  # CoralRPCHandler handles communicating with a Coral service via Coral-RPC, including
  # serializing to and from structures.
  class CoralRPCHandler < Coral::Handler
    include Coral::CoralRPCTranslator
    include Coral::Support::Logging

    # Handle serializing parameters into a request hash, and set up
    # the options for the HTTP request (to be handled by HTTPHandler).
    def before(job)
      request = job.request

      # Both the operation name and service name are string model ids.
      operation_name = request[:operation_name]
      service_name = request[:service_name]

      param_data = structure_to_coral_rpc(request[:value])

      request[:http_verb] = 'POST'
      request[:http_content_type] = 'application/json; charset=UTF-8'

      http_data_hash = {
        "Operation" => operation_name,
        "Service" => service_name
      }
      http_data_hash['Input'] = param_data if param_data

      request[:http_data] = Coral::Support::JsonHelper.generate(http_data_hash)
      logger.info "Making request to operation #{operation_name} with parameters #{request[:http_data]}"
    end

    # Deserialize the response from JSON and build out structure objects
    # from it.
    def after(job)
      reply = job.reply

      fail "Received response body nil. Please make sure that the service you are trying to reach works properly." if reply[:value].nil?
      logger.info "Received response body: #{reply[:value]}"

      json_result = nil
      begin
        json_result = Coral::Support::JsonHelper.parse(reply[:value])
      rescue Exception => e
        logger.error(e.message)
        code = reply[:http_status_code]
        message = reply[:http_status_message]

        raise "#{code} : #{message}" unless code.to_i == 200
        raise "Failed parsing response: #{$!}\n"
      end

      # TODO: in the future, check the coral version
      if json_result['Output']
        reply[:value] = structure_from_coral_rpc(json_result['Output'])
      else
        reply[:value] = nil
      end
    end

  end
end

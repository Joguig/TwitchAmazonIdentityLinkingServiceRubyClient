require 'coral/identity_handler'
require 'coral/coral_rpc_handler'
require 'coral/http_handler'
require 'coral/http_destination_handler'
require 'coral/orchestrator'
require 'coral/support/logging'
require 'coral/awsv4_signature_handler'
require 'coral/gat_sending_handler'
require 'coral/gat_receiving_handler'

module Coral

  # Constructs an orchestrator for use with the Coral-RPC protocol.
  module CoralRPC
    extend Coral::Support::Logging

    IDENTITY_KEYS = [:http_authorization, :http_client_x509_cert,
                     :http_client_x509_key, :aws_access_key_id, :aws_secret_key, :security_token]
    VALID_ARGS = [:endpoint, :uri, :ca_file, :verbose,
                  :timeout, :connect_timeout,
                  :v4_signatures, :gat_sending_strategy, :gat_sending_publisher, :gat_sending_storage,
                  :http_proxy_options] + IDENTITY_KEYS

    # Creates an Orchestrator capable of processing Coral-RPC requests.  Possible arguments include:
    # [:endpoint]
    #   The HTTP URL at which the service is located.
    # [:http_client_x509_cert]
    #   A base64-encoded X509 certificate to sign outgoing requests.
    #   Requires that the x509 key also be specified.
    # [:http_client_x509_key]
    #   A base64-encoded private key for an X509 certificate to sign outgoing requests.
    #   Requires that the x509 certificate also be specified.
    # [:http_authorization]
    #   The content of an http-authorization header to send with the request.
    #   Used for services which require HTTP basic authentication.
    # [:ca_file]
    #   A Certificate Authority file to pass to the HttpHandler.
    # [:timeout]
    #   The socket read timeout to use during service calls (see HttpHandler for details)
    # [:connect_timeout]
    #   A timeout to use for establishing a connection to the service (see HttpHandler for details)
    # [:verbose]
    #   A verbosity flag to pass to the HttpHandler.
    # [:v4_signatures]
    #   A map of AWS v4 signature options. If missing, V4 signatures are not used.
    # [:gat_sending_strategy]
    #   An object that overrides the default GAT metrics generation strategy for sent calls
    #   Default is Amazon::Gat::AlwaysFalseStrategy.new
    # [:gat_sending_publisher]
    #   An object that overrides the default GAT metrics publisher for sent calls
    #   Default is Amazon::Gat::Publisher.new
    # [:gat_sending_storage]
    #   An object that overrides the default GAT metrics storage for sent calls
    #   Default is Amazon::Gat::ThreadLocalStorage.new
    # [:http_proxy_options]
    #   This contains the :addr, and optionally :port, :user and :pass
    #   in case using a proxy is desired. Otherwise, this should be nil.
    #
    # Example usage:
    #   orchestrator = CoralRPC.new_orchestrator(:endpoint => "http://localhost:8000")
    #   client = ExampleClient.new(orchestrator)
    #
    def self.new_orchestrator(args)
      check_args(args)
      return Orchestrator.new(new_chain(args))
    end

    private

    def self.new_chain(args)
      # build up the chain:
      chain = []

      # allow user to preload identity attributes to be used on all requests
      identity_args = {}
      IDENTITY_KEYS.each do |k|
        identity_args[k] = args[k] if args.has_key?(k)
      end

      chain << IdentityHandler.new(identity_args) unless identity_args.empty?

      # set the remote endpoint
      chain << HttpDestinationHandler.new(args[:endpoint])

      # use the CoralRPC protocol
      chain << CoralRPCHandler.new


      # optionally use AWS V4 signatures
      chain << AWSV4SignatureHandler.new(args[:v4_signatures]) if args[:v4_signatures]

      # including GAT handler
      begin
        chain << GatSendingHandler.new(args)
      rescue Exception => e
        logger.warn(e.message)
      end

      # make connection over HTTP
      chain << HttpHandler.new( {:ca_file => args[:ca_file], :verbose => args[:verbose],
                                  :timeout => args[:timeout], :connect_timeout => args[:connect_timeout],
                                  :http_proxy_options => args[:http_proxy_options]})

      return chain
    end

    def self.check_args(args)
      args.each_key do |key|
        raise ArgumentError.new("Unknown argument: #{key}") unless VALID_ARGS.include?(key)
      end
    end

  end

end

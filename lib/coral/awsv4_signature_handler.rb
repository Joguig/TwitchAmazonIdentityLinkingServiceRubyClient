require 'coral/handler'
require 'coral/support/logging'
require 'time'
require 'openssl'
require 'digest'

module Coral
  # Implementation of the AWS v4 signature algorithm.
  #
  # TODO: this does not support GET requests that have query parameters.
  # TODO: this does not support session tokens
  class AWSV4SignatureHandler < Coral::Handler
    include Coral::Support::Logging

    # Setup a new signature handler.
    #
    # [:region]
    #   The region name for the service, such as 'us-east-1'. Required.
    # [:service]
    #   The name of the service. Optional.
    def initialize(options)
      @region = options[:region]
      raise ArgumentError.new("A :region parameter is required.") unless @region

      @service = options[:service]
    end

    def before(job)
      # register as the authentication token provider
      job.request[:auth_token_proxy] = self
      # register as the date provider
      job.request[:request_date_proxy] = self

      job.request[:http_uri] = URI(job.request[:endpoint]) if job.request[:http_uri].nil? && !job.request[:endpoint].nil?
      job.request[:http_uri].path = '/' if job.request[:http_uri].path.nil? || job.request[:http_uri].path.empty?
      job.request[:http_host] = job.request[:http_uri].host
    end

    def generate_request_date(request)
      # V4 sigs require ISO8601 dates, so override the default provided by Coral::HTTPHandler
      request_date(request).utc.strftime("%Y%m%dT%H%M%SZ")
    end

    # for overriding in testing
    def request_date(request)
      Time.now
    end

    # Sign the request and return the signature.
    def generate_authorization_token(request)
      identity = request[:identity] || {:aws_access_key_id => request[:aws_access_key_id], :aws_secret_key => request[:aws_secret_key]}

      raise ArgumentError.new("Missing :aws_access_key_id in identity") unless identity[:aws_access_key_id]
      raise ArgumentError.new("Missing :aws_secret_key in identity") unless identity[:aws_secret_key]

      # we explicitly don't support query parameters yet, so fail early
      unless request[:http_uri].query.nil? or request[:http_uri].query == ""
        raise ArgumentError.new("Query parameters are not yet supported")
      end

      get_authorization_header(
        identity[:aws_access_key_id],
        identity[:aws_secret_key],
        request[:http_verb],
        request[:http_uri].path,
        request[:http_headers],
        request[:http_data],
        @service || request[:service_name],
        @region)
    end

    def get_authorization_header(access_key_id, secret_key, verb, uri_path, headers, payload, service, region)
      signed_headers = headers_to_sign(headers)

      canonical_request = canonicalize_request(verb, uri_path, headers, signed_headers, payload)
      logger.debug { "Canonicalized request: '#{canonical_request}'" }

      timestamp = headers['X-Amz-Date']
      derivation_date = timestamp[0..7]
      scope = create_scope(derivation_date, region, service)
      string_to_sign = create_string_to_sign("AWS4-HMAC-SHA256", timestamp, scope, canonical_request);
      logger.debug { "String to sign: '#{string_to_sign}'" }

      signing_key = derive_key(secret_key, derivation_date, region, service);
      signature = hex16(hmac(string_to_sign, signing_key))

      parts = []
      parts << "AWS4-HMAC-SHA256 Credential=#{access_key_id}/#{scope}"
      parts << "SignedHeaders=#{signed_headers}"
      parts << "Signature=#{signature}"
      parts.join(', ')
    end

    def create_string_to_sign(algorithm, timestamp, scope, canonical_request)
      parts = []
      parts << algorithm
      parts << timestamp
      parts << scope
      parts << hex16(hash(canonical_request))
      parts.join("\n")
    end

    def canonicalize_request(verb, uri_path, headers, signed_headers, payload)
      parts = []
      parts << verb
      parts << uri_path
      parts << '' # canonicalized parameters, for CoralRPC this is empty
      parts << canonicalize_headers(headers)
      parts << signed_headers
      parts << hex16(hash(payload))
      parts.join("\n")
    end

    # +headers+ is a Coral::HTTPHeaders object
    def canonicalize_headers(headers)
      headers = headers.to_hash

      pairs = []
      headers.keys.sort.each do |key|
        next if key == 'authorization'

        values = headers[key].map(&:to_s).map(&:strip).join(',')
        pairs << ["#{key}:#{values}"]
      end

      pairs.join("\n") + "\n"
    end

    def headers_to_sign(headers)
      to_sign = headers.names.dup
      to_sign.delete('authorization')
      to_sign.sort.join(";")
    end

    def create_scope(derivation_date, region, service)
      "#{derivation_date}/#{region}/#{service}/aws4_request"
    end

    def derive_key(secret_key, derivation_date, region, service)
      k_date = hmac(derivation_date, "AWS4" + secret_key);
      k_region = hmac(region, k_date);
      k_service = hmac(service, k_region);

      hmac("aws4_request", k_service);
    end

    def hmac(string, key)
      OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, string)
    end

    def hash(string)
      Digest::SHA256.digest(string)
    end

    def hex16(string)
      string.unpack('H*').first
    end
  end
end

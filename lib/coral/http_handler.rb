require 'net/http'
require 'net/https'
require 'coral/handler'
require 'coral/http_headers'
require 'coral/support/logging'
require 'time'
require 'amazon/cacerts'

module Coral

  # Executes HTTP requests via the Net::HTTP library.  Supports HTTP, HTTPS and client X509 certificates.
  class HttpHandler < Handler
    include Coral::Support::Logging

    # Instantiate a new HttpHandler with the specified arguments.  Possible arguments include:
    # [:verbose]
    #   If true, the handler will output the URI it is requesting to STDOUT.
    #   This may be useful for debugging purposes.
    # [:ca_file]
    #   This parameter's value points to a valid .pem certificate file to enable the
    #   client to validate server certificates when using SSL.
    #   If this parameter is not specified, the client operates in insecure mode and does not
    #   validate that server certificates come from a trusted source.
    # [:timeout]
    #   This value (in seconds) will be used for every socket operation during the request.
    #   Note that since a request can involve many socket operations, calls that timeout may
    #   actually take more time than this value.  If unspecified, defaults to 5.0 seconds.
    #   A value of zero will result in an infinite timeout.
    # [:connect_timeout]
    #   This value (in seconds) will be used as the timeout for opening a connection to the
    #   service.  If unspecified, defaults to 5.0 seconds.  A value of zero will result in
    #   an infinite timeout.
    # [:http_proxy_options]
    #   This contains the :addr, and optionally :port, :user and :pass
    #   in case using a proxy is desired. Otherwise, this should be nil.
    def initialize(args = {})
      @verbose = args[:verbose]
      @ca_file = args[:ca_file]
      @connect_timeout = args[:connect_timeout]
      @timeout = args[:timeout]

      @connect_timeout = 5.0 if @connect_timeout.nil?
      @timeout = 5.0 if @timeout.nil?

      if args[:http_proxy_options].nil? || args[:http_proxy_options].empty?
        @http_class = Net::HTTP
      else
        proxy_options = args[:http_proxy_options]
        @http_class = Net::HTTP.Proxy(proxy_options[:addr], proxy_options[:port],
          proxy_options[:user], proxy_options[:pass])
      end

      raise ArgumentError, "connect_timeout must be non-negative" if @connect_timeout < 0
      raise ArgumentError, "timeout must be non-negative" if @timeout < 0
    end

    def before(job)
      identity = job.request[:identity]
      request_id = job.request[:id]
      uri = job.request[:http_uri]
      verb = job.request[:http_verb]

      job.request[:http_verb] = verb = 'GET' if verb.nil?

      # grab any headers already in the job, make sure we put the headers object back into the job
      # since the AuthTokenProxy may need it
      job.request[:http_headers] = HttpHeaders.new if job.request[:http_headers].nil?
      headers = job.request[:http_headers]
      # grab any headers that was requestedx as a complete overwrite, which erases existing values  
      overwrite_headers = job.request[:http_overwrite_headers]
      headers['x-amzn-RequestId'] = "#{request_id}"
      headers['x-amzn-Delegation'] = identity[:http_delegation] unless identity[:http_delegation].nil?
      headers['Authorization'] = identity[:http_authorization] unless identity[:http_authorization].nil?
      headers['x-amz-security-token'] = identity[:security_token] unless identity[:security_token].nil?
      headers['Host'] = job.request[:http_host] unless job.request[:http_host].nil?
      headers['Content-Type'] = job.request[:http_content_type] unless job.request[:http_content_type].nil?
      headers['Accept'] = job.request[:http_accept] unless job.request[:http_accept].nil?
      headers['X-Amz-Date'] = get_request_date(job.request)
      headers['x-amzn-ActionTrace'] = job.request[:identity][:GLOBAL_ACTION_TRACE]
      headers['X-Amzn-Client-TTL-Seconds'] = @timeout.to_s

      # https://w.amazon.com/index.php/Coral/Specifications/HttpTarget
      if headers['x-amz-target'].nil?
        # Both service_name and operation_name may be namespace qualified
        target_svc = job.request[:service_name]
        target_op = job.request[:operation_name]

        unless target_svc.nil? || target_op.nil?
          formatted_svc = target_svc.sub /\#/, '.'
          formatted_op = target_op.sub /^[^\#]*\#/, ''

          headers['x-amz-target'] = "#{ formatted_svc }.#{ formatted_op }"
        end
      end

      auth_token_proxy = job.request[:auth_token_proxy]
      if(auth_token_proxy)
        token = auth_token_proxy.generate_authorization_token(job.request)
        if(token.nil?)
          logger.debug "No Authorization token was generated for this request"
        else
          if ((token.downcase.start_with?('basic ')) ||
              (token.downcase.start_with?('aws4-hmac-sha256 ')))
            headers['Authorization'] = token unless headers['Authorization']
          else
            headers['x-amzn-Authorization'] = token unless headers['x-amzn-Authorization']
          end
        end
      end

      identity[:http_client_x509_cert] ||= identity[:http_client_x509] # CU-4085

      result = http_request(uri, headers, verb, job.request[:http_data], identity[:http_client_x509_cert], identity[:http_client_x509_key], overwrite_headers)

      logger.info "Response code: #{result.code}"

      replyHeaders = job.reply[:http_headers] = HttpHeaders.new
      result.each_name do |n|
        result.get_fields(n).each do |v|
          replyHeaders.add_value(n, v)
        end
      end

      job.reply[:value] = result.body
      job.reply[:http_status_code] = result.code
      job.reply[:http_status_message] = result.message
    end

    private
    def get_request_date(request)
      date_proxy = request[:request_date_proxy]
      date_proxy ? date_proxy.generate_request_date(request) : Time.now.httpdate
    end

    def http_request(uri, headers, verb, http_data = nil, cert = nil, key = nil, overwrite_headers = nil)
      logger.info "Requesting URL #{uri}; headers #{headers}" # TODO: remove this log? headers could leak user passwords
      puts "Requesting URL:\n#{uri}\nQuery string:\n#{http_data}\n" if @verbose

      http = @http_class.new(uri.host, uri.port)
      http.read_timeout = @timeout
      http.open_timeout = @connect_timeout

      if(uri.scheme == 'https')
        # enable SSL
        http.use_ssl = true

        # if we haven't been given CA certificates to check, disable certificate verification (otherwise we'll get repeated warnings to STDOUT)
        if @ca_file.nil?
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        else
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.ca_file = @ca_file
          store = OpenSSL::X509::Store.new
          store.set_default_paths
          http.cert_store = store
        end

        # negotiate with the client certificate, if one is present
        unless(cert.nil? || key.nil?)
          http.cert = OpenSSL::X509::Certificate.new(cert)
          http.key = OpenSSL::PKey::RSA.new(key)
        end
      end

      if verb == 'GET'
        request = Net::HTTP::Get.new(uri.request_uri)
      elsif verb == 'POST'
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = http_data
      else
        raise "Unrecognized http_verb: #{http_verb}"
      end

      headers.to_hash.each do |n, a|
        a.each do |v|
          request.add_field(n, v)
        end
      end
      # any header value in overwrite_headers will do replacement of existing fields
      unless overwrite_headers.nil? 
        overwrite_headers.to_hash.each do |n, a|
           a.each do |v|
               request[n] = v
           end
        end
      end

      http.start do |http|
        http.request(request)
      end
    end

  end

end

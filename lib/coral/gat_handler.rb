require 'amazon/gat/span'
require 'amazon/gat/trace'
require 'coral/handler'
require 'coral/support/logging'

module Coral
=begin
  The GATHandler class is meant to be extended by the receiving and sending handlers of GAT, in order to
  provide GAT functionality to the CoralRubySuperClient.

  In this class, the common instance variables and methods are stored. There are three important
  and required members of this class:
    - _storage:_ usually Amazon::Gat::ThreadLocalStorage, used for storing the current trace and iid
    - _publisher:_ usually Amazon::Gat::Publisher, used to send the trace and span to the GAT server
    - _decision_strategy:_ (e.g.: Amazon::Gat::CountBasedStrategy) used to set a specific strategy to generate traces

  For more information about GAT, please visit https://w.amazon.com/index.php/GAT
=end
  class GatHandler < Coral::Handler

    attr_accessor :storage, :publisher, :decision_strategy
    include Coral::Support::Logging

=begin
    Creates a new trace every time the current trace is null and the _decision_strategy_ should generate  and
    proceeds with publishing the trace either way.
=end
    def make_trace_if_needed (job, caller, span_type, identity)
      if @storage.class.get_trace.nil? && @decision_strategy.should_generate?
        @storage.class.set_trace Amazon::Gat::Trace.new
      end
      publish_new_span_with_trace_lookup job, caller, span_type, identity
    end

=begin
    Returns the name of the coral service. In case the application is not a coral service or has not been set up well,
    *"UNKNOWN"* is returned.
=end
    def app_name job
      return "UNKNOWN" if job.nil? || job.request.nil? || job.request[:service_name].nil? || job.request[:service_name].empty?
      job.request[:service_name].split(/#/).last
    end

=begin
    Returns +true+ if *any* of the three required instance attributes is nil.
=end
    def local_variables_not_valid
      return @storage.nil? || @publisher.nil? || @decision_strategy.nil?
    end

=begin
    Publishes a new generated span and the trace given, and returns the span.
=end
    def publish_new_span job, trace, caller, span_type, iid
      request = job.request
      service = request[:service_name]
      if service.nil? or service.empty?
        service_model = ServiceHelper.service_model job
        service = service_model.id.name
        service ||= caller
      end
      operation_name = request[:operation_name]
      if operation_name.nil? or operation_name.empty?
        service_model = ServiceHelper.operation_model job
        operation_name = model.id.name
      end
      span = Amazon::Gat::Span.new(
       {:caller => caller,
        :target_method_name => operation_name.split(/#/).last,
        :target => service.split(/#/).last,
        :iid => iid})
      span.add_user_data [request[:id]]
      span.span_type=span_type
      begin
        @publisher.publish trace, span
      rescue Exception => e
        logger.warn e.message
      end
      logger.debug "generated trace=#{span.generate_gat_id(trace)};span=#{span.to_s}" if logger.debug?
      span
    end

=begin
    If the current trace is not nil, this method proceeds with publishing it, creating a new span
    and updates the request identity
=end
    def publish_new_span_with_trace_lookup job, caller, span_type, identity
      unless @storage.class.get_trace.nil?
        trace = @storage.class.get_trace
        span = publish_new_span job, trace, caller, span_type, nil
        update_request identity, trace, span
      end
    end

=begin
    Updates the request identity to store the _:GLOBAL_ACTION_TRACE_ and _:SPAN_INTERACTION_ID_
=end
    def update_request identity, trace, span
      if identity[:GLOBAL_ACTION_TRACE].nil? or identity[:GLOBAL_ACTION_TRACE].empty?
        identity[:GLOBAL_ACTION_TRACE] = span.generate_gat_id trace
      end
      identity[:IDENTITY_OP_START_INTERACTION_KEY] = span.iid unless identity.nil?
    end

=begin
  Sets the current trace if the id has already been stored in the request
=end
    def set_trace_if_any trace_id
      begin
        t = Amazon::Gat::Trace.parse_gat_id_to_trace trace_id
        logger.warn("Could not parse traceId received in the request. traceid: #{trace_id}") if t.nil?
        return t
      rescue Exception => e
        logger.warn("Could not parse traceId received in the request. traceid: #{trace_id}")
      end
    end
=begin
    Returns the service name from the request
=end
    def get_service_name_from_request(request)
      request[:service_name]
    end
  end
end
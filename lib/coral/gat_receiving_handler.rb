require 'amazon/gat/span'
require 'amazon/gat/trace'
require 'amazon/gat/publisher'
require 'amazon/gat/thread_local_storage'
require 'amazon/gat/count_based_strategy'
require 'coral/gat_handler'
require 'coral/support/logging'

module Coral
=begin
  This class extends the GatHandler class and is meant to publish traces to the GAT daemon for the
  incoming calls
=end
  class GatReceivingHandler < Coral::GatHandler

=begin
    The constructor of the receiving side handler that does the required parameters initialization
=end
    def initialize(args={})
      @decision_strategy = args[:gat_receiving_strategy] || Amazon::Gat::CountBasedStrategy.new
      @publisher = args[:gat_receiving_publisher] || Amazon::Gat::Publisher.new
      @storage = args[:gat_receiving_storage] || Amazon::Gat::ThreadLocalStorage.new
      raise Exception.new("Unable to participate in tracing because trace handler has not been configured correctly.") if (local_variables_not_valid)
    end

=begin
    The handler method used before treating the call.
=end
    def before(job)
      @storage.class.set_trace nil
      identity = job.request[:identity]
      identity[:HTTP_ACTUAL_ADDRESS] = "UNKNOWN"
      identity[:HTTP_ACTUAL_ADDRESS] = job.request[:http_uri].to_s.split(/\//)[2].split(/:/).first unless job.request[:http_uri].nil?
      if not identity[:GLOBAL_ACTION_TRACE].nil? and not identity[:GLOBAL_ACTION_TRACE].empty?
        set_trace_if_any identity[:GLOBAL_ACTION_TRACE]
        publish_new_span_with_trace_lookup(job, identity[:HTTP_ACTUAL_ADDRESS],
          Amazon::Gat::Span::SERVER_REQUEST_SPAN_TYPE, identity) unless job.request[:id].nil?
      else
        make_trace_if_needed job, identity[:HTTP_ACTUAL_ADDRESS], Amazon::Gat::Span::SERVER_REQUEST_SPAN_TYPE, identity
      end
      job.metrics[:GLOBAL_ACTION_TRACE] = @storage.class.get_trace.origin_id unless @storage.class.get_trace.nil? || job.metrics.nil?
    end

=begin
    The handler method used after treating the call.
=end
    def after(job)
      unless @storage.class.get_trace.nil?
        identity = job.request[:identity]
        span = publish_new_span(job, @storage.class.get_trace, identity[:HTTP_ACTUAL_ADDRESS],
          Amazon::Gat::Span::SERVER_REPLY_SPAN_TYPE, identity[:IDENTITY_OP_START_INTERACTION_KEY])
        job.reply[:http_headers] ||= {}
        http_headers = job.reply[:http_headers]
        http_headers[:X_AMZN_ACTION_TRACE_NAME]=span.generate_gat_id @storage.class.get_trace
        @storage.class.set_trace nil
      end
    end

  end
end

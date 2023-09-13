require 'amazon/gat/span'
require 'amazon/gat/trace'
require 'amazon/gat/publisher'
require 'amazon/gat/always_false_strategy'
require 'amazon/gat/thread_local_storage'
require 'coral/gat_handler'
require 'coral/support/logging'

module Coral
=begin
  This class extends the GatHandler class and is meant to publish traces to the GAT daemon for the
  outgoing calls
=end
  class GatSendingHandler < Coral::GatHandler

=begin
    The constructor of the sending side handler that does the required parameters initialization
=end
    def initialize(args={})
      @decision_strategy = args[:gat_sending_strategy] || Amazon::Gat::AlwaysFalseStrategy.new
      @publisher = args[:gat_sending_publisher] || Amazon::Gat::Publisher.new
      @storage = args[:gat_sending_storage] || Amazon::Gat::ThreadLocalStorage.new
      raise Exception.new("Unable to participate in tracing because trace handler has not been configured correctly.") if (local_variables_not_valid)
    end

=begin
    The handler method used before treating the call.
=end
    def before(job)
      identity = job.request[:identity]
      make_trace_if_needed job,app_name(job), Amazon::Gat::Span::CLIENT_REQUEST_SPAN_TYPE, identity
      job.metrics[:GLOBAL_ACTION_TRACE] = @storage.class.get_trace.origin_id unless @storage.class.get_trace.nil? || job.metrics.nil?
    end

=begin
    The handler method used after treating the call.
=end
    def after(job)
      t = @storage.class.get_trace
      unless t.nil?
        identity = job.request[:identity]
        iid = nil
        iid = identity[:IDENTITY_OP_START_INTERACTION_KEY] unless identity.nil?
        publish_new_span job, @storage.class.get_trace, app_name(job), Amazon::Gat::Span::CLIENT_REPLY_SPAN_TYPE, iid
      else
        if !job.reply[:http_headers].nil? && !job.reply[:http_headers]['x-amzn-ActionTrace'].nil?
          identity = job.request[:identity]
          trace_id = job.reply[:http_headers]['x-amzn-ActionTrace']
          identity[:GLOBAL_ACTION_TRACE] = trace_id unless identity.nil?
          t = set_trace_if_any trace_id
          publish_new_span job, t, get_service_name_from_request(job.request),Amazon::Gat::Span::CLIENT_REPLY_SPAN_TYPE, nil unless t.nil?
        end
      end
    end

  end
end

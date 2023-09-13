# GatReceivingFilter
#
# == Description
# This filter can be added into a controller's filter chain 
# to generated GAT spans.
#
# == Example
# require 'amazon/gat/publisher'
# require 'amazon/gat/always_true_strategy'
# require 'amazon/gat/filter/gat_receiving_filter'
#
# class ChangesController < ActionController::Base
#   around_filter Amazon::Gat::Filter::GatReceivingFilter
#
#   #   
#   # initialize the filter
#   #
#   publisher = Amazon::Gat::Publisher.new
#   strategy = Amazon::Gat::AlwaysTrueStrategy.new
#   service_name = "YourServiceName"
#   Amazon::Gat::Filter::GatReceivingFilter.init(publisher, strategy,
#   service_name)
#
#   def action
#     # omitted...
#   end
# end

require 'amazon/gat/trace'
require 'amazon/gat/thread_local_storage'
require 'amazon/gat/publisher'
require 'amazon/gat/span'

module Amazon
  module Gat
    module Filter
      # This filter publishes two spans (one request span and one reply
      # span) around each request.
      # The request span is published before the request is processed.
      # The reply span is published after the request is processed.
      #
      # The trace and span creation logics are copied from 
      # amazon.actiontrace.generation.servlet.TraceOnReceiveServletFilter.
      class GatReceivingFilter
        def self.init(publisher, strategy, service_name, logger = nil)
          raise ArgumentError, "publisher is not specified" unless publisher 
          raise ArgumentError, "strategy is not specified" unless strategy
          raise ArgumentError, "service name is not specified" unless service_name

          @@publisher = publisher
          @@strategy = strategy
          @@service_name = service_name
          @@logger = logger
        end

        #
        # A round filter for GAT span publishing
        #
        def self.filter(controller)
          trace = nil
          span = nil
          exp = nil

          # reset trace and iid for this thread
          Amazon::Gat::ThreadLocalStorage.set_trace(nil)
          Amazon::Gat::ThreadLocalStorage.set_iid(nil)
          
          # look up or create the trace
          trace_id = controller.request.headers['x-amzn-ActionTrace']
          if trace_id
            begin
              trace = Amazon::Gat::Trace.parse_gat_id_to_trace(trace_id)
            rescue => e
              if @@logger
                @@logger.error("failed to parse trace id #{trace_id}:" + e.message)
              end
            end
          else
            if @@strategy.should_generate?
              trace = Amazon::Gat::Trace.new
            end
          end

          # publish the request span
          if trace
            span = Amazon::Gat::Span.new({
              :caller => controller.request.remote_ip,
              :target => @@service_name,
              :target_method_name => controller.request.method,
              :span_type => Amazon::Gat::Span::SERVER_REQUEST_SPAN_TYPE
            })
            publish_span(trace, span)

            # set trace and iid in storage
            # so that downstream codes can 
            # use them
            Amazon::Gat::ThreadLocalStorage.set_trace(trace)
            Amazon::Gat::ThreadLocalStorage.set_iid(span.iid)
          end

          begin
            # yield to controller 
            # to hanle the request
            yield
          rescue  => exp
            raise exp
          ensure
            # publish reply span
            if trace
              iid = nil
              if not span.iid.nil?
                iid = span.iid
              end

              s = Amazon::Gat::Span.new({
                :iid => iid,
                :caller => controller.request.remote_ip,
                :target => @@service_name,
                :target_method_name => controller.request.method,
                :span_type => Amazon::Gat::Span::SERVER_REPLY_SPAN_TYPE
              })

              if exp 
                s.add_statuses(["be:#{exp.message}"])
              end
              publish_span(trace, s)
            end
          end
        end

        #
        # publishes the given trace and span
        #
        def self.publish_span(trace, span)
          @@publisher.publish(trace, span)
        rescue => e
          if @@logger
            @@logger.error("failed to publish trace #{trace} and span #{span}: " + e.message)
          end
        end
      end
    end
  end
end

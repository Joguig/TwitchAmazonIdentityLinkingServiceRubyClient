# Publisher
# 
# == Description
# Publisher is used to send trace and span data to 
# a predefined UDP port on local host.
# 
# Publisher will not throw exceptions.  When error
# occurs, it simply log the error message in stderr.
#
# == Exceptions
# Throws Exceptions if Publisher is unable to bind UDP port 
# or unable to send out data.
#
# == Examples
# require 'amazon/gat/trace'
# require 'amazon/gat/span'
# require 'amazon/gat/publisher'
#
# begin
#   publisher = Amazon::Gat::Publisher.new
#   trace = Amazon::Gat::Trace.new
#   span = Amazon::Gat::Span.new
#   publisher.publish(trace, span)
# rescue Exception => e
#   // log error 
# end
require 'socket'
require 'thread'

require 'amazon/gat/protocol'

module Amazon
  module Gat
    class Publisher
      def initialize(port = 12333)
        @port = port
      end

      def publish(trace, span)
        return if trace.nil? || span.nil?

        UDPSocket.open do |s|
          s.connect 'localhost', @port 
          s.send(Amazon::Gat::Protocol.serialize(trace, span), 0)
        end
      rescue Exception => e
        raise Exception, "unable to publish data: #{e.message}"
      end
    end
  end
end

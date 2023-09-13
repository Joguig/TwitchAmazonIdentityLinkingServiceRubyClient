# Protocol 
#
# == Description
# Protocol is used to serialize trace and span. 
#
# == Examples
# require 'amazon/gat/protocol'
#
# trace = Trace.new
# span = Span.new
# str = Amazon::Gat::Protocol.serialize(trace, span)
require 'amazon/gat/constants'
require 'amazon/gat/uuid'

module Amazon
  module Gat
    class Protocol
      def self.serialize(trace, span)
        str = "%s%s:%s;%s:%s;%s:%s;%s:%s;%s:%s;%s:%s;%s:%s;%s:%s;%s;%s;" % 
        [ self.serialize_origin_id(trace.origin_id), 
          Amazon::Gat::Constants::TRACE_DEPTH[:protocol], 
          trace.depth,
          Amazon::Gat::Constants::TRACE_PID[:protocol],
          trace.parent_interaction_id,
          Amazon::Gat::Constants::SPAN_INTERACTION_ID[:protocol],
          span.iid,
          Amazon::Gat::Constants::SPAN_CREATION_DATETIME[:protocol],
          span.creation_date.strftime('%Q'),
          Amazon::Gat::Constants::SPAN_CALLER[:protocol],
          span.caller,
          Amazon::Gat::Constants::SPAN_TARGET[:protocol],
          span.target,
          Amazon::Gat::Constants::SPAN_TARGET_METHOD[:protocol],
          span.target_method_name,
          Amazon::Gat::Constants::SPAN_TYPE[:protocol],
          span.span_type,
          self.serialize_user_data(span.user_data),
          self.serialize_statuses(span.statuses)
        ]

        # first two bytes are the length of str
        str = ["%04x" % str.size].pack('H*') + str

        # each datagram is 512 bytes
        str.ljust(512, "\0")[0..511]
      end
     
      def self.serialize_user_data(user_data)
        user_data.select {|d| (not d.nil?) && (not d.empty?)}.map do |d|
          "#{Amazon::Gat::Constants::SPAN_USER_DATA[:protocol]}:#{d}" 
        end.sort.join(";")
      end

      def self.serialize_statuses(statuses)
        statuses.select {|d| (not d.nil?) && (not d.empty?)}.map do |d|
          "#{Amazon::Gat::Constants::SPAN_STATUSES[:protocol]}:#{d}" 
        end.sort.join(";")
      end

      def self.serialize_origin_id(origin_id)
        Amazon::Gat::UUID.uuid_to_bitstr(origin_id)
      end
    end
  end
end

# GAT Constants
#
# == Description
# Each constant has two values. One value is for display, e.g. be used 
# in to_s method. The other value is for protocol, e.g. be used in 
# Protocol.serialize method.
#
# == Example
#
# === Get the name of constant SPAN_TYPE
# require 'amazon/gat/constants'
# span_type_for_display = Amazon::Gat::Constants::SPAN_TYPE[:name]
#
# === Get the protocol value of constant SPAN_TYPE
# require 'amazon/gat/constants'
# span_type_for_protocol = Amazon::Gat::Constants::SPAN_TYPE[:protocol]
#
module Amazon
  module Gat
    class Constants
      def self.add(key, value)
        @hash ||= {}
        @hash[key] = value || {}
      end

      def self.const_missing(key)
        @hash[key]
      end

      def self.each
        @hash.each {|key, value| yield(key, value)}
      end

      self.add(:TRACE_CONTAINER_NAME, {:name => "AGAT", :protocol => "a"})
      self.add(:TRACE_ORIGIN_ID, {:name => "originId", :protocol => "o"})
      self.add(:TRACE_DEPTH, {:name => "depth", :protocol => "d"})
      self.add(:TRACE_PID, {:name => "parentIteractionId", :protocol => "pid"})
      self.add(:SPAN_INTERACTION_ID, {:name => "iteractionId", :protocol => "iid"})
      self.add(:SPAN_CALLER, {:name => "caller", :protocol => "ca"})
      self.add(:SPAN_TARGET, {:name => "spanTarget", :protocol => "t"})
      self.add(:SPAN_TARGET_METHOD, {:name => "spanTargetMethod", :protocol => "tm"})
      self.add(:SPAN_CREATION_DATETIME, {:name => "spanCreation", :protocol => "c"})
      self.add(:SPAN_STATUSES, {:name => "statuses", :protocol => "s"})
      self.add(:SPAN_USER_DATA, {:name => "userData", :protocol => "u"})
      self.add(:SPAN_TYPE, {:name => "spanType", :protocol => "y"})
    end 
  end
end

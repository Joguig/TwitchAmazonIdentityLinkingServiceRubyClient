# GAT Span 
# 
# == Description
# Each service call should generate four spans - two from the client
# side and two from the server side. 
#
# Suppose service A calls service B and both A and B are integrated 
# to GAT. The four spans will be:
# * client sending span. Service A will publish a span of type 
#   CLIENT_REQUEST_SPAN_TYPE before it initiate the service call.
# * server receiving span. Service B will publish a span of type
#   SERVER_REQUEST_SPAN_TYPE after it receives the call request.
# * server sending span. Service B will publish a span of type 
#   SERVER_REPLY_SPAN_TYPE after it sends the result back to A.
# * client receving span. Service A will publish a span of type 
#   CLIENT_REPLY_SPAN_TYPE after it receives the result of service B.
#
# For details, please check "Amazon Global Action Trace" specification 
# at https://w.amazon.com/index.php/GAT.
#
# Span contains the follow data. 
# * iid, a 6-letter base 64 encoded random number. 
# * caller, the name of the service that initiate the call
# * target_method_name, the method name of the callee
# * target, the service name of the callee
# * creation_date, span creation time. 
# * user_data, a string set used to store user data. Users can put
#   any string in user_data. 
# * statuses, a string set used to store span statuses, e.g. 
#   apollo environment name, stage name, log files, etc.
# * span_type - the type of the span
#
# iid and create_date will be automatically generated if the user
# does not specify explicitly in constructor arguments.
# Other attributes have to be set by the user, either via constructor
# or via setter methods.
#
# == Examples
#
# === create a span
# require 'amazon/gat/span'
#
# span = Amazon::Gat::Span.new({
#           :caller => "ProductAggregatorService",
#           :target => "PARISService", 
#           :target_method_name => "getMarketplaceByID",
#           :user_data => ["important_span"], 
#           :span_type => Amazon::Gat::Span::SERVER_REQUEST_SPAN_TYPE})
# span.add_env("ProductAgregatorService")
# span.add_stage("Beta")
# span.add_logfile("ProductAggregatorService.log")
#
# === generate gat id 
# require 'amazon/gat/span'
#
# trace = Amazon::Gat::Trace.new
# span = Amazon::Gat::Span.new
# gat_id = span.generate_gat_id(trace)
require 'base64'
require 'set'
require 'date'

require 'amazon/gat/constants'

module Amazon
  module Gat
    class Span
      attr_accessor :caller, :target_method_name, :target, :iid
      attr_accessor :creation_date, :span_type, :user_data, :statuses
      
      SERVER_REQUEST_SPAN_TYPE = "R"
      SERVER_REPLY_SPAN_TYPE = "P"
      CLIENT_REQUEST_SPAN_TYPE = "Q"
      CLIENT_REPLY_SPAN_TYPE = "Y"

      def initialize(config = {})
        @iid = config[:iid] || self.class.generate_iid(6)
        @caller = config[:caller] || ""
        @target_method_name = config[:target_method_name] || ""
        @target = config[:target] || ""
        @creation_date = config[:creation_date] || DateTime.now
        @user_data = config[:user_data] || Set.new
        @statuses = config[:statuses] || Set.new
        @span_type = config[:span_type] || ""
      end

      #
      # merge the given statuses into the 
      # span's status set.
      #
      def add_statuses(statuses)
        @statuses.merge(statuses)
      end

      #
      # merge the given user data set into the 
      # span's user_data set.
      #
      def add_user_data(data)
        @user_data.merge(data)
      end

      # 
      # add apollo environment name 
      #
      def add_env(env)
        return if env.nil? || env.empty?
        @statuses.add("e:#{env}")
      end

      #
      # add apollo stage 
      #
      def add_stage(stage)
        return if stage.nil? || stage.empty?
        @statuses.add("s:#{stage}")
      end

      #
      # add file name
      #
      def add_logfile(file_name)
        return if file_name.nil? || file_name.empty?
        @statuses.add(file_name)
      end

      #
      # returns string value of the span
      #
      def to_s
        "%s:%s;%s:%s;%s:%s;%s:{%s};%s:{%s};" % 
        [ Amazon::Gat::Constants::SPAN_INTERACTION_ID[:name], 
          @iid, 
          Amazon::Gat::Constants::SPAN_CREATION_DATETIME[:name], 
          @creation_date.to_s, 
          Amazon::Gat::Constants::SPAN_TYPE[:name], 
          @span_type, 
          Amazon::Gat::Constants::SPAN_USER_DATA[:name], 
          @user_data.sort.to_a.join(","), 
          Amazon::Gat::Constants::SPAN_STATUSES[:name], 
          @statuses.sort.to_a.join(",")
         ]
      end

      #
      # returns gat id
      #
      def generate_gat_id(trace)
        "amzn1.tr.%s.%d.%s.%s" % [trace.origin_id, trace.depth, trace.parent_interaction_id, @iid]
      end

      #
      # generate interaction id
      #
      def self.generate_iid(size)
        if size < 0
          size = 0
        end

        # generate a random number in [0, 2**64-1]
        random = rand(0xffffffffffffffff)
        Base64.encode64(random.to_s).chomp("\n")[0,size]
      end
    end
  end
end

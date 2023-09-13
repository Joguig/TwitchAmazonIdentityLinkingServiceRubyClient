# CountBasedStrategy
#
# == Description
# On most services, GAT traces are generated for only a small percentage of
# requests. CountBasedStrategy can be used to control the sampling rate, e.g.
# to create trace for one percent of the requests.
#
# == Exceptions
# Throws ArgumentError if 
# * counter is negative, or
# * threshold is negative, or
# * counter is greater than threshold
#
# == Example
#
# === Create a strategy that returns true for every 100 calls
# require 'amazon/gat/count_based_strategy'
# strategy = Amazon::Gat::CountBasedStrategy.new(0, 100)
# 
# if strategy.should_generate?
#    // generate trace
# end
module Amazon
  module Gat
    class CountBasedStrategy
      attr_reader :counter, :threshold

      def initialize(counter=0, threshold=100)
        @counter = counter || 0
        @threshold = threshold || 100

        raise ArgumentError, 'threshold must be a number greater than 0' unless @threshold >= 0
        raise ArgumentError, 'count must be a number in [0..threshold]' unless @counter >= 0 && @counter <= @threshold
      end

      def should_generate?
        @counter += 1
        if (@counter >= @threshold)
          @counter = 0
          return true
        end

        return false
      end
    end
  end
end

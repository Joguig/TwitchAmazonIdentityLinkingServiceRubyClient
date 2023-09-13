# AlwaysTrueStrategy
#
# == Description
# AlwaysTrueStrategy always returns true in should_generate? method.
# GAT integration on sending side should usually use AlwaysFalseStrategy.
# See wiki https://w.amazon.com/index.php/Global_Trace/User_Documentation/Coral_and_Codigo_Support
# for details.
#
# == Example
#
# === Create a strategy that returns true for every 100 calls
# require 'amazon/gat/always_true_strategy'
# strategy = Amazon::Gat::AlwaysTrueStrategy.new
# 
# if strategy.should_generate?
#    // generate trace
# end
module Amazon
  module Gat
    class AlwaysTrueStrategy
      def initialize
      end

      def should_generate?
        true
      end
    end
  end
end

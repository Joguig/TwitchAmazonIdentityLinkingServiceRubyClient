# AlwaysFalseStrategy
#
# == Description
# AlwaysFalseStrategy always returns false in should_generate? method.
# GAT integration on sending side should usually use AlwaysFalseStrategy.
# See wiki https://w.amazon.com/index.php/Global_Trace/User_Documentation/Coral_and_Codigo_Support
# for details.
#
# == Example
#
# === Create a strategy that returns true for every 100 calls
# require 'amazon/gat/always_false_strategy'
# strategy = Amazon::Gat::AlwaysFalseStrategy.new
# 
# if strategy.should_generate?
#    // generate trace
# end
module Amazon
  module Gat
    class AlwaysFalseStrategy
      def initialize
      end

      def should_generate?
        false
      end
    end
  end
end

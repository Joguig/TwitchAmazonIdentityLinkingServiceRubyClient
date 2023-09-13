# ThreadLocalStorage for GAT
#
# == Description
#
# ThreadLocalStorage can be used to store and retrieve
# current trace and iid for the current thread. Current trace
# and iid are stored in Thread.current[:gat_trace] and
# Thread.current[:gat_iid]
#
# == Examples
#
# require 'amazon/gat/trace'
# require 'amazon/gat/thread_local_storage'
# 
# trace = Amazon::Gat::Trace.new
# Amazon::Gat::ThreadLocalStorage.set_trace(trace)
# ...
# trace = Amazon::Gat::ThreadLocalStorage.get_trace
module Amazon
  module Gat
    class ThreadLocalStorage
      def self.set_trace(trace)
        Thread.current[:gat_trace] = trace
      end

      def self.get_trace
        Thread.current[:gat_trace]
      end

      def self.set_iid(iid)
        Thread.current[:gat_iid] = iid
      end

      def self.get_iid
        Thread.current[:gat_iid] 
      end
    end
  end
end

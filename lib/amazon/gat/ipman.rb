# IpMan
#
# == Description 
# IpMan can be used to retrieve the non-loopback ip address
# of the host.
#
# == Example
# require 'amazon/gat/ipman'
#
# ip = Amazon::Gat::IpMan.get_local_ip
require 'socket'

module Amazon
  module Gat
    class IpMan
      #
      # gets the local ip address
      #
      # The code was copied from
      # http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/.
      # It is because Socket.ip_address_list is not available in Ruby 1.8.
      #
      def self.get_local_ip
        # turn off reverse DNS resolution temporarily.
        # we are interested in ip address, not host name.
        orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

        # This code does NOT make a connection or send any packet 
        # (to 72.21.215.232 which is amazon.com). It merely makes a
        # system call which figures out how to route the packets 
        # based on the address and what interface (and therefore IP
        # address) it should bind to. Method addr() returns an array
        # containing the family (AF_INET), local port, and local 
        # address of the socket.
        UDPSocket.open do |s|
          s.connect '72.21.215.232', 1
          s.addr.last
        end
      ensure
        Socket.do_not_reverse_lookup = orig
      end
    end
  end
end

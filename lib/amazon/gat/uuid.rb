# UUID
#
# == Description
# A utility class for UUID generation. 
#
# GAT UUID has a special property. The last two bytes are duplicates of 
# the two bytes before them.  Suppose len is the length of uuid, the 
# following condifions should hold:
#   uuid[len-1] equals uuid[len-3] 
#   uuid[len-2] equlas uuid[len-4]
#
# For example, f4a77e7a-72b9-11e2-aa32-0ae30a190a19 is one valid Gat uuid.
#
# == Examples
#
# === create a random UUID
# require 'amazon/gat/uuid'
# uuid = UUID.gat_uuid
#
# === get bit string for a specific uuid
# require 'amazon/gat/uuid'
# bitstr = UUID.uuid_to_bitstr("f4a77e7a-72b9-11e2-aa32-0ae30a190a19")
require 'time'
require 'securerandom'
require 'amazon/gat/ipman'

module Amazon
  module Gat
    class UUID
      # Generates GAT UUID.
      # 
      # @see com.fasterxml.uuid.impl.TimeBasedGenerator
      # @see www.ietf.org/rfc/rfc4122.txt
      def self.gat_uuid
        time = uuid_timestamp
        random_seq = SecureRandom.hex(2)
        node = fake_mac_addr
        "%s-%s-%s" % [time, random_seq, node]
      end

      def self.uuid_to_bitstr(uuid)
        hex = uuid.gsub(/-/, '')
        [hex].pack('H*')
      end

      def self.bitstr_to_uuid(bitstr)
        hex = bitstr.unpack('H*')[0]
        hex.unpack('a8a4a4a4a*').join('-')
      end

      #
      # private methods
      #

      # GAT uses fake mac address in UUID.
      # The fake mac address has 6 bytes, the first 4 bytes
      # are ip addresses, and the last two bytes are duplicates
      # of the last two bytes in ip addresses.
      def self.fake_mac_addr
        ip = Amazon::Gat::IpMan.get_local_ip
        iphex = "%02x%02x%02x%02x" % ip.split(/\./).map{|i| i.to_i}
        # duplicate the last two bytes
        iphex += iphex[-4, 4]
      end

      # Generates a timestamp that can be used to
      # construct UUID.
      #
      # @see com.fasterxml.uuid.impl.TimeBasedGenerator
      # @see www.ietf.org/rfc/rfc4122.txt
      def self.uuid_timestamp
        milli_seconds = (Time.now.to_f * 1000).to_i

        # translate milliseconds to what UUID needs, 100ns
        # unit offset from the beginning of Gregorian calendar.
        uuid_timestamp = (milli_seconds * 10000) + 0x01b21dd213814000 

        # expand timestamp to 8 bytes
        bytes = to_byte_array(uuid_timestamp)

        # The first 4 bits is UUID type.
        # The type of timestamp based UUID is 1.
        first = bytes[0]
        first &= 0X0F
        first |= 0X10

        second = bytes[1]

        "%02x%02x%02x%02x-%02x%02x-%02x%02x" % (bytes[4,4] + bytes[2,2] + [first] + [second])
      end

      # convert the given number to byte array
      def self.to_byte_array(num)
        result = []
        begin
          result << (num & 0xff)
          num >>= 8
        end until (num == 0 || num == -1)
        result.reverse
      end

      private_class_method :fake_mac_addr, :uuid_timestamp, :to_byte_array
    end
  end
end

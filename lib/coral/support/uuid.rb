#--
# UUIDTools, Copyright (c) 2005-2008 Bob Aman
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# This is an abbreviated version of the file http://tiny/9xpc/uuidtoolsrb
# from the RubyGen-uuidtools packages; it has been copied locally in
# order to avoid taking a dependency on an external package.
#
# Ruby provides native UUID support as of version 1.9.2; once we no
# longer need to support older versions of Ruby, we should remove this
# class and use SecureRandom.uuid instead.

require 'uri'
require 'time'

begin
  require 'securerandom'
rescue LoadError
  require File.join(File.dirname(__FILE__), 'compat', 'securerandom')
end

module Coral
module Support
  #= coral_uuidtools.rb
  #
  # UUIDTools was designed to be a simple library for generating any
  # of the various types of UUIDs.  It conforms to RFC 4122 whenever
  # possible.
  #
  #== Example
  #  UUID.random_create
  #  => #<UUID:0x19013a UUID:984265dc-4200-4f02-ae70-fe4f48964159>
  class UUID
    include Comparable

    @@last_timestamp = nil
    @@last_node_id = nil
    @@last_clock_sequence = nil
    @@state_file = nil

    def initialize(time_low, time_mid, time_hi_and_version,
        clock_seq_hi_and_reserved, clock_seq_low, nodes)
      unless time_low >= 0 && time_low < 4294967296
        raise ArgumentError,
          "Expected unsigned 32-bit number for time_low, got #{time_low}."
      end
      unless time_mid >= 0 && time_mid < 65536
        raise ArgumentError,
          "Expected unsigned 16-bit number for time_mid, got #{time_mid}."
      end
      unless time_hi_and_version >= 0 && time_hi_and_version < 65536
        raise ArgumentError,
          "Expected unsigned 16-bit number for time_hi_and_version, " +
          "got #{time_hi_and_version}."
      end
      unless clock_seq_hi_and_reserved >= 0 && clock_seq_hi_and_reserved < 256
        raise ArgumentError,
          "Expected unsigned 8-bit number for clock_seq_hi_and_reserved, " +
          "got #{clock_seq_hi_and_reserved}."
      end
      unless clock_seq_low >= 0 && clock_seq_low < 256
        raise ArgumentError,
          "Expected unsigned 8-bit number for clock_seq_low, " +
          "got #{clock_seq_low}."
      end
      unless nodes.kind_of?(Enumerable)
        raise TypeError,
          "Expected Enumerable, got #{nodes.class.name}."
      end
      unless nodes.size == 6
        raise ArgumentError,
          "Expected nodes to have size of 6."
      end
      for node in nodes
        unless node >= 0 && node < 256
          raise ArgumentError,
            "Expected unsigned 8-bit number for each node, " +
            "got #{node}."
        end
      end
      @time_low = time_low
      @time_mid = time_mid
      @time_hi_and_version = time_hi_and_version
      @clock_seq_hi_and_reserved = clock_seq_hi_and_reserved
      @clock_seq_low = clock_seq_low
      @nodes = nodes
    end

    attr_accessor :time_low
    attr_accessor :time_mid
    attr_accessor :time_hi_and_version
    attr_accessor :clock_seq_hi_and_reserved
    attr_accessor :clock_seq_low
    attr_accessor :nodes

    # Parses a UUID from a string.
    def self.parse(uuid_string)
      unless uuid_string.kind_of? String
        raise TypeError,
          "Expected String, got #{uuid_string.class.name} instead."
      end
      uuid_components = uuid_string.downcase.scan(
        Regexp.new("^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-" +
          "([0-9a-f]{2})([0-9a-f]{2})-([0-9a-f]{12})$")).first
      raise ArgumentError, "Invalid UUID format." if uuid_components.nil?
      time_low = uuid_components[0].to_i(16)
      time_mid = uuid_components[1].to_i(16)
      time_hi_and_version = uuid_components[2].to_i(16)
      clock_seq_hi_and_reserved = uuid_components[3].to_i(16)
      clock_seq_low = uuid_components[4].to_i(16)
      nodes = []
      for i in 0..5
        nodes << uuid_components[5][(i * 2)..(i * 2) + 1].to_i(16)
      end
      return self.new(time_low, time_mid, time_hi_and_version,
        clock_seq_hi_and_reserved, clock_seq_low, nodes)
    end

    # Parses a UUID from a raw byte string.
    def self.parse_raw(raw_string)
      unless raw_string.kind_of? String
        raise TypeError,
          "Expected String, got #{raw_string.class.name} instead."
      end
      integer = self.convert_byte_string_to_int(raw_string)

      time_low = (integer >> 96) & 0xFFFFFFFF
      time_mid = (integer >> 80) & 0xFFFF
      time_hi_and_version = (integer >> 64) & 0xFFFF
      clock_seq_hi_and_reserved = (integer >> 56) & 0xFF
      clock_seq_low = (integer >> 48) & 0xFF
      nodes = []
      for i in 0..5
        nodes << ((integer >> (40 - (i * 8))) & 0xFF)
      end
      return self.new(time_low, time_mid, time_hi_and_version,
        clock_seq_hi_and_reserved, clock_seq_low, nodes)
    end

    # Parses a UUID from an Integer.
    def self.parse_int(uuid_int)
      unless uuid_int.kind_of?(Integer)
        raise ArgumentError,
          "Expected Integer, got #{uuid_int.class.name} instead."
      end
      return self.parse_raw(self.convert_int_to_byte_string(uuid_int, 16))
    end

    # Parse a UUID from a hexdigest String.
    def self.parse_hexdigest(uuid_hexdigest)
      unless uuid_hexdigest.kind_of?(String)
        raise ArgumentError,
          "Expected String, got #{uuid_hexdigest.class.name} instead."
      end
      return self.parse_int(uuid_hexdigest.to_i(16))
    end

    # Creates a UUID from a random value.
    def self.random_create()
      new_uuid = self.parse_raw(SecureRandom.random_bytes(16))
      new_uuid.time_hi_and_version &= 0x0FFF
      new_uuid.time_hi_and_version |= (4 << 12)
      new_uuid.clock_seq_hi_and_reserved &= 0x3F
      new_uuid.clock_seq_hi_and_reserved |= 0x80
      return new_uuid
    end

    # This method applies only to version 1 UUIDs.
    # Checks if the node ID was generated from a random number
    # or from an IEEE 802 address (MAC address).
    # Always returns false for UUIDs that aren't version 1.
    # This should not be confused with version 4 UUIDs where
    # more than just the node id is random.
    def random_node_id?
      return false if self.version != 1
      return ((self.nodes.first & 0x01) == 1)
    end

    # Returns true if this UUID is the
    # nil UUID (00000000-0000-0000-0000-000000000000).
    def nil_uuid?
      return false if self.time_low != 0
      return false if self.time_mid != 0
      return false if self.time_hi_and_version != 0
      return false if self.clock_seq_hi_and_reserved != 0
      return false if self.clock_seq_low != 0
      self.nodes.each do |node|
        return false if node != 0
      end
      return true
    end

    # Returns the UUID version type.
    # Possible values:
    # 1 - Time-based with unique or random host identifier
    # 2 - DCE Security version (with POSIX UIDs)
    # 3 - Name-based (MD5 hash)
    # 4 - Random
    # 5 - Name-based (SHA-1 hash)
    def version
      return (time_hi_and_version >> 12)
    end

    # Returns the UUID variant.
    # Possible values:
    # 0b000 - Reserved, NCS backward compatibility.
    # 0b100 - The variant specified in this document.
    # 0b110 - Reserved, Microsoft Corporation backward compatibility.
    # 0b111 - Reserved for future definition.
    def variant
      variant_raw = (clock_seq_hi_and_reserved >> 5)
      result = nil
      if (variant_raw >> 2) == 0
        result = 0x000
      elsif (variant_raw >> 1) == 2
        result = 0x100
      else
        result = variant_raw
      end
      return (result >> 6)
    end

    # Returns true if this UUID is valid.
    def valid?
      if [0b000, 0b100, 0b110, 0b111].include?(self.variant) &&
        (1..5).include?(self.version)
        return true
      else
        return false
      end
    end

    # Returns the IEEE 802 address used to generate this UUID or
    # nil if a MAC address was not used.
    def mac_address
      return nil if self.version != 1
      return nil if self.random_node_id?
      return (self.nodes.collect do |node|
        sprintf("%2.2x", node)
      end).join(":")
    end

    # Returns the timestamp used to generate this UUID
    def timestamp
      return nil if self.version != 1
      gmt_timestamp_100_nanoseconds = 0
      gmt_timestamp_100_nanoseconds +=
        ((self.time_hi_and_version  & 0x0FFF) << 48)
      gmt_timestamp_100_nanoseconds += (self.time_mid << 32)
      gmt_timestamp_100_nanoseconds += self.time_low
      return Time.at(
        (gmt_timestamp_100_nanoseconds - 0x01B21DD213814000) / 10000000.0)
    end

    # Compares two UUIDs lexically
    def <=>(other_uuid)
      check = self.time_low <=> other_uuid.time_low
      return check if check != 0
      check = self.time_mid <=> other_uuid.time_mid
      return check if check != 0
      check = self.time_hi_and_version <=> other_uuid.time_hi_and_version
      return check if check != 0
      check = self.clock_seq_hi_and_reserved <=>
        other_uuid.clock_seq_hi_and_reserved
      return check if check != 0
      check = self.clock_seq_low <=> other_uuid.clock_seq_low
      return check if check != 0
      for i in 0..5
        if (self.nodes[i] < other_uuid.nodes[i])
          return -1
        end
        if (self.nodes[i] > other_uuid.nodes[i])
          return 1
        end
      end
      return 0
    end

    # Returns a representation of the object's state
    def inspect
      return "#<UUID:0x#{self.object_id.to_s(16)} UUID:#{self.to_s}>"
    end

    # Returns the hex digest of the UUID object.
    def hexdigest
      return self.to_i.to_s(16).rjust(32, "0")
    end

    # Returns the raw bytes that represent this UUID.
    def raw
      return self.class.convert_int_to_byte_string(self.to_i, 16)
    end

    def empty?
      return true if self.to_s.length == 0
      false
    end

    # Returns a string representation for this UUID.
    def to_s
      result = sprintf("%8.8x-%4.4x-%4.4x-%2.2x%2.2x-", @time_low, @time_mid,
        @time_hi_and_version, @clock_seq_hi_and_reserved, @clock_seq_low);
      for i in 0..5
        result << sprintf("%2.2x", @nodes[i])
      end
      return result.downcase
    end
    alias_method :to_str, :to_s

    # Returns an integer representation for this UUID.
    def to_i
      @integer ||= (begin
        bytes = (time_low << 96) + (time_mid << 80) +
          (time_hi_and_version << 64) + (clock_seq_hi_and_reserved << 56) +
          (clock_seq_low << 48)
        for i in 0..5
          bytes += (nodes[i] << (40 - (i * 8)))
        end
        bytes
      end)
    end

    # Returns a URI string for this UUID.
    def to_uri
      return "urn:uuid:#{self.to_s}"
    end

    # Returns an integer hash value.
    def hash
      @hash ||= self.to_i % 0x3fffffff
    end

    # Returns true if this UUID is exactly equal to the other UUID.
    def eql?(other)
      return self == other
    end

    # The following methods are not part of the public API,
    # and generally should not be called directly.

    def self.convert_int_to_byte_string(integer, size) #:nodoc:
      byte_string = ""
      if byte_string.respond_to?(:force_encoding)
        byte_string.force_encoding(Encoding::ASCII_8BIT)
      end
      for i in 0..(size - 1)
        byte_string << ((integer >> (((size - 1) - i) * 8)) & 0xFF)
      end
      return byte_string
    end

    def self.convert_byte_string_to_int(byte_string) #:nodoc:
      if byte_string.respond_to?(:force_encoding)
        byte_string.force_encoding(Encoding::ASCII_8BIT)
      end
      integer = 0
      size = byte_string.size
      for i in 0..(size - 1)
        ordinal = (byte_string[i].respond_to?(:ord) ?
          byte_string[i].ord : byte_string[i])
        integer += (ordinal << (((size - 1) - i) * 8))
      end
      return integer
    end
  end
end
end

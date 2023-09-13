module Coral
  module Support
    module JsonHelper
      class << self
        attr_accessor :use_yajl
      end
      self.use_yajl = true

      def self.generate(data)
        if use_yajl
          Yajl::Encoder.encode(data)
        else
          JSON.generate(data, :max_nesting => false)
        end
      end

      def self.parse(data)
        if use_yajl
          Yajl::Parser.parse(data)
        else
          JSON.parse(data, :max_nesting => false)
        end
      end
    end
  end
end

require 'rubygems'
begin
  require 'yajl'
  Coral::Support::JsonHelper.use_yajl = true
rescue LoadError
  Coral::Support::JsonHelper.use_yajl = false
  require 'json'
end

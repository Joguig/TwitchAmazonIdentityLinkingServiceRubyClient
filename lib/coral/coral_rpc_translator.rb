require 'coral/support/logging'

module Coral
  # CoralRPCTranslator handles serializing to and from structures.
  module CoralRPCTranslator
    include Coral::Support::Logging

    # Convert individual values to Coral hashes, recursively.
    def value_to_coral_rpc(data, expected_type = nil)
      if data.nil?
        return nil
      elsif data.is_a? ::Time
        return format_time(data)
      elsif data.is_a? ::Date
        return format_time(Time.parse(data.to_s))
      elsif data.is_a?(::Integer)
        return data
      elsif data.is_a?(::Float)
        if data.nan?
          return "NaN"
        elsif data.infinite?
          return (data > 0 ? "" : "-") + "Infinity"
        else
          return data
        end
      elsif data.is_a? ::Array
        return data.map {|item| value_to_coral_rpc(item, expected_type.first) }
      elsif data.is_a? ::Hash
        result = {}
        data.each_pair do |key, value|
          result[key.to_s] = value_to_coral_rpc(value, expected_type.values.first)
        end
        return result
      elsif data.is_a? Coral::Structure
        return structure_to_coral_rpc(data, expected_type)
      else
        return data.to_s
      end
    end

    def format_time x
      ("%.3f" % x.to_f).to_f
    end

    # TODO: probably need a concept of "nearest enclosing structure"

    # Convert a Structure type to a Coral-RPC hash. This is broken out from value_to_coral_rpc
    # because it's more complicated.
    # The optional type parameter gives the "expected" type of the structure as declared in
    # the coral member, so that we don't have to emit the __type field all the time.
    def structure_to_coral_rpc(structure, expected_type = nil)
      return nil unless( structure && structure.class.respond_to?(:coral_members) )

      coral_hash = {}

      structure.class.coral_members.each_value do |member|
        value = structure.send("#{member.ruby_name}")
        if !value.nil?
          coral_hash[member.name] = value_to_coral_rpc(value, member.type)
        end
      end

      # Tell Coral what type this is. We can omit this if it's the "expected" type and not a subclass.
      # TODO: We could be even smarter and omit the namespace for subclasses that share a namespace with
      # their enclosing context.
      # TODO: I think we still have to specify it if the actual structure's namespace is different
      #       from the nearest enclosing structure.
      coral_hash['__type'] = structure.class.model_id.to_s unless (expected_type && expected_type == structure.class)

      coral_hash
    end

    # Convert coral hashes to Ruby types. Uses the shape type description from the coral_member declaration.
    #   * If the type arg is a Symbol, it's a simple type
    #   * If the type arg is a Class, it's a structure
    #   * If the type arg is a Array, it will contain a single item that is a description of the contents of the list.
    #   * If the type arg is a Hash, it will have a single value that describes map values. Keys are strings.
    def value_from_coral_rpc(data, type, &block)
      # simple types are expressed with symbols
      if type.is_a? ::Symbol
        # TODO: how to support blob types? For now they're sent/recieved as Base64 strings

        # Handle Timestamps specially
        if type == :Timestamp
          return ::Time.at(data).utc
        elsif type == :Float || type == :Double
          if data == "NaN"
            return 0.0/0.0
          elsif data == "Infinity"
            return 1.0/0.0
          elsif data == "-Infinity"
            return -1.0/0.0
          else
            return data
          end
        else
          # Everything else comes in from the JSON parser in the right Ruby datatype
          return data
        end

      elsif type.is_a? ::Class  # Structures are actual class objects
        return (data.nil? ? data : structure_from_coral_rpc(data, type, &block))

      elsif type.is_a? ::Array  # For arrays, convert each item of the array
        item_type = type.first

        return (data || []).map do |item|
          value_from_coral_rpc(item, item_type, &block)
        end

      elsif type.is_a? ::Hash   # Hashes need both just the value converted - keys are strings.
        result = {}
        value_type = type.values.first

        (data || {}).each_pair do |key, value|
          result[key] = value_from_coral_rpc(value, value_type, &block)
        end

        return result
      end
    end

    # Dig into a type descriptor until you find the class or symbol inside it. For example, if you start with:
    # [ { :values => [ [ Foo::Bar ] ] } ] you'd get back Foo::Bar.
    def deep_type(type)
      if type.is_a?(::Class) || type.is_a?(::Symbol) || type.nil?
        return type
      elsif type.is_a? ::Hash
        return deep_type(type.values.flatten.first)
      elsif type.is_a? ::Array
        return deep_type(type.flatten.first)
      end
    end

    # Convert a JSON hash into a structure.
    # json_result is a hash from JSON. type is an optional type if we already know it from the
    # member definition. The type from the response's "__type" field is always used if it's defined,
    # though.
    #
    # Note: exception classes get unmarshalled and returned like normal objects - they don't get raised here!
    def structure_from_coral_rpc(coral_hash, type = nil, &block)
      coral_type = coral_hash['__type'] || type

      unless coral_type.is_a?(Class)
        model_id = ModelId.new(coral_type)

        # This handles cases where the type is just a name, which assumes it's in the same namespace as the
        # member.
        # TODO: I don't think that's correct - it uses the same namespace as the "nearest enclosing type"
        if !model_id.namespace
          model_id.namespace = type.model_id.namespace
        end

        begin
          coral_type = model_id.model_class
        rescue NameError # if the type couldn't be loaded, it's probably a new type of exception since this client was generated
          return ::Coral::UnknownException.new("#{model_id.to_s}: #{coral_hash['message'] || coral_hash['Message'] || 'No message'}")
        end
      end

      instance = create_coral_instance(coral_type, coral_hash, &block)
      initialize_coral_instance(instance, coral_hash, &block)
      instance
    end

    # Creates a new instance of the given type.
    # This method provides a hook for extending packages to customize the types returned as part of the deserialization process.
    # (For example, ActiveCoral overrides this method to return instances of locally defined classes, rather than coral structures).
    #
    # coral_type:: A class
    # coral_hash:: A CoralRPC hash
    def create_coral_instance(coral_type, coral_hash, &block)
      # Exceptions get treated specially, since they take a message.
      if coral_type.ancestors.include?(Coral::Exception)
        coral_type.new(coral_hash['message'] || coral_hash['Message'] || 'No message')
      else
        coral_type.new(&block)
      end
    end

    # Intialize the instance with the provided Hash.
    # This method provides a hook for extending packages to customize how the newly created instances are initialized.
    # (For example, ActiveCoral overrides this method to support lazy instantiation, rather than the recursive instantion defined here).
    #
    # instance:: An instance of a ::Coral::Structure
    # coral_hash:: A CoralRPC hash
    def initialize_coral_instance(instance, coral_hash, &block)
      instance.class.coral_members.each_value do |member|
        if !coral_hash[member.name].nil?
          instance.send "#{member.ruby_name}=", value_from_coral_rpc(coral_hash[member.name], member.type, &block)
        end
      end

      instance
    end

  end
end


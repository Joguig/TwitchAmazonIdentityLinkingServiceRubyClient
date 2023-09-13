module Coral

  # Represents a model ID (usually in the form "com.amazon.myservice#MyType"). Allows for querying
  # parts of the ID (name, namespace) as well as retrieving the corresponding Ruby class with model_class.
  class ModelId
    attr_accessor :namespace
    attr_accessor :name

    # Initialize a ModelId with a string like "com.amazon.myservice#MyType".
    def initialize(model_id_string)
      id_parts = model_id_string.split(/#/)

      if id_parts.size == 1
        self.name = id_parts.first
      else
        self.namespace = id_parts[0]
        self.name = id_parts[1]
      end
    end

    # Returns the full id string, like "com.amazon.myservice#MyType".
    def to_s
      if namespace
        "#{namespace}##{name}"
      else
        name
      end
    end

    # Returns the ruby class name as a string. For example, given "com.amazon.myservice#MyType", it would return
    # "Com::Amazon::Myservice::MyType".
    def ruby_class_name
      raise ArgumentError.new("Cannot produce a ruby class name for a Model Id with no namespace") unless namespace
      # Cache the class name
      @ruby_class_name ||= self.to_s.split(/[\.#]/).map {|s| s[0,1].upcase + s[1..-1]}.join('::')
    end

    # Retrieve a Ruby class corresponding to the model id. Raises a NameError if there is no such
    # class. It will attempt to require the file containing the class if it hasn't been required already.
    # For example, given "com.amazon.myservice#MyType", it would return the class
    # Com::Amazon::Myservice::MyType.
    def model_class
      # Cache types so we don't look them up over and over
      return @ruby_class unless @ruby_class.nil?

      klass = self.class.get_constant(ruby_class_name)

      # Try to require the corresponding file and reload. This helps support "generic"
      # Coral exception types that won't be known and required ahead of time.
      if klass.nil?
        begin
          require Coral::Support::Inflections.underscore(ruby_class_name)
          klass = self.class.get_constant(ruby_class_name)
        rescue LoadError # If we couldn't load the file, that's OK.
        end
      end

      # If it still wasn't found,
      raise NameError.new("Uninitialized constant #{ruby_class_name}") if klass.nil?

      @ruby_class = klass
    end

    # Support comparing ModelIds for equality
    def eql?(other)
      return true if self.equal?(other)
      return false unless self.class.equal?(other.class)

      return self.to_s == other.to_s
    end

    # == should use eql for value-equality
    alias == eql?

    # Implement hashcode for ModelIds, so they can go in hashes and sets.
    def hash
      self.to_s.hash
    end

    private

    # Given an arbitrary class/module name string like "Coral::Zephyr::DBException", return
    # the class/module or nil if it doesn't exist.
    def self.get_constant(var)
      var.split(/::/).inject(Object) do |left, right|
        begin
          return nil unless left.const_defined?(right)
          (Module.method(:const_get).arity == 1) ? left.const_get(right) : left.const_get(right, false)
        rescue NameError
          return nil
        end
      end
    end
  end

  # Extend this module from a class to give that class the ability to set and retrieve
  # a model id that corresponds to that class. First, extend HasModelId, then call
  # set_model_id in the class body to set the model id, which can be retrieved via
  # MyClass.model_id.
  module HasModelId

    # Declares the ModelId associated with this class. Call this when defining a class.
    def set_model_id(model_id)
      @model_id = model_id.is_a?(Coral::ModelId) ? model_id : Coral::ModelId.new(model_id)
    end

    # Get the ModelId associated with this class.
    # Set the model id with set_model_id.
    def model_id
      @model_id
    end
  end
end

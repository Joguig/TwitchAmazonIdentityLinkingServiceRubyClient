require 'coral/support/inflections'
require 'coral/model_id'

module Coral
  module Support
    # StructureBuilder is a module that can be included in a class to give it the ability to declare coral members,
    # and then be initialized from hashes, and provide information about its members for use in marshalling. It is a
    # module instead of a base class because we want Coral::Exception to behave like a Coral structure, but also have
    # StandardError as a parent class, and we don't have true multiple inheritance available to us.
    #
    # Individual structures are described using the set_model_id and coral_member class methods. This allows structure definitions
    # to be entirely descriptive, with implementation being generated at runtime. Each new structure must set its model id
    # by calling set_model_id its class definition. Then, each member is defined with a call to coral_member, giving its
    # name and input and output types (if it has any).
    #
    # Note: In order for polymorphic unmarshalling to work, the Structure class *must* be named after its Coral model id. So
    # if the model id is com.amazon.myservice#MyType, the Ruby class must be Com::Amazon::Myservice::MyType.
    module StructureBuilder
      # Whenever this is included, also extend the class with ClassMethods and Model ID properties.
      def self.included(base)
        base.extend Coral::HasModelId
        base.extend ClassMethods
      end

      # Construct a new structure. Params can be passed in
      # to specify the value of each member of the structure. If the type of a member is
      # another structure, you can pass a hash in its place and that hash will be used to construct
      # that structure, and so forth, or you can just provide your own instance of the structure.
      #
      # For example, you could initialize a MyStuffQuery structure in either of these ways:
      #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
      #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
      def initialize(options = {})
        options = {} if options.nil?
        if options.is_a? Hash
          initialize_coral_structure(options)
        else
          super
        end
      end

      # Check the declared validation rules from the Coral model, returning all errors as an array.
      # TODO: make this compatible with ActiveModel somehow? Do other validations too? At least make it reflectable...
      #       ActiveModel also will validate everything and return it all at once, rather than one at a time.
      def validate
        errors = []

        self.class.coral_members.each_value do |member|
          member_value = self.send(member.ruby_name)

          errors.concat(member.validate(member_value))
          errors.concat(validate_member(member_value).map { |error| "#{member.ruby_name}#{error}" })
        end

        errors
      end

      # Tests for deep value equality - two structures are equal if they are the same instance,
      # or if they are the same class and all members are equal.
      def eql?(other)
        return true if self.equal?(other)
        return false unless self.class.equal?(other.class)

        # Check equality between all members
        self.class.coral_members.each_value do |member|
          member_value = self.send(member.ruby_name)
          other_member_value = other.send(member.ruby_name)

          return false unless member_value == other_member_value
        end

        return true
      end

      # == should use eql for value-equality
      alias == eql?

      # Implement hashcode for structures, so they can go in hashes and sets.
      # Compute a hashcode based on all the member values.
      def hash
        # Start off with the hash code of the model_id
        hashcode = self.class.model_id.hash

        self.class.coral_members.each_value do |member|
           # XOR the hash codes for each member, which maintains the uniform distribution.
          hashcode ^=  "#{member.ruby_name}#{self.send(member.ruby_name).hash.to_s}".hash
        end

        hashcode
      end

      private

      # Recursively validate deep structures. Called by validate.
      def validate_member(member_value)
        errors = []

        # Recursively validate structures
        if member_value.respond_to? :validate
          errors.concat(member_value.validate.map { |error| ".#{error}" })
        elsif member_value.is_a? Array
          member_value.each_with_index do |item,i|
            errors.concat(validate_member(item).map { |error| "[#{i}]#{error}" })
          end
        elsif member_value.is_a? Hash
          member_value.each do |k,item|
            errors.concat(validate_member(item).map { |error| "['#{k}']#{error}" })
          end
        end

        errors
      end

      # Construct a new structure. Params can be passed in
      # to specify the value of each member of the structure. If the type of a member is
      # another structure, you can pass a hash in its place and that hash will be used to construct
      # that structure, and so forth, or you can just provide your own instance of the structure.
      #
      # For example, you could initialize a MyStuffQuery structure in either of these ways:
      #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
      #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
      #
      # Handles the initialization of Coral structure members from a hash, including recursively constructing other
      # structures.
      def initialize_coral_structure(options={})
        options.each_pair do |key, value|
          member = self.class.coral_members[key.to_s]

          if !member.nil?
            self.send "#{key.to_s}=", convert_value(value, member.type)
          else
            raise ArgumentError.new("\"#{key}\" is not a recognized attribute for #{self.class.name}. Valid attributes are #{self.class.coral_members.values.map(&:ruby_name).inspect}")
          end
        end
      end

      # Recursively convert values to structures.
      def convert_value(param, type)
        return nil if param.nil?

        if type.is_a? Class
          if param.is_a?(Hash)
            [:__type, '__type'].each do |special_type_key|
              type = ModelId.new(param.delete(special_type_key)).model_class if param[special_type_key]
            end
            return type.new(param)
          else
            return param
          end
        elsif type.is_a? Array
          item_type = type.first

          return param.map do |item|
            convert_value(item, item_type)
          end

        elsif type.is_a? Hash # Hashes need just the values converted - keys are always strings.
          result = {}
          value_type = type.values.first

          param.each_pair do |key, value|
            result[key] = convert_value(value, value_type)
          end

          return result
        else
          return param
        end
      end

      module ClassMethods
        # Declares a member of the structure, which will be added as an attribute of the
        # structure class with a Rubyish underscored name. (for example, myFancyStatus becomes my_fancy_status).
        #
        # The :type option describes the type of the member, and is required.
        # * Simple shapes are just the shape name as a symbol,
        #   like :String or :InfoQuery
        # * Structure types are the actual class of the generated Ruby structure type
        # * Lists are a Ruby list containing the type of object in the list,
        #   like [ :String ]. This allows for nested lists/maps like [ [ :Integer ] ]
        # * Maps are a Ruby hash with a single entry describing the value type (the key
        #   is always a string), like { :values => :Integer }. Again, this
        #   allows expressing nesting.
        #
        # Validations can also be expressed. Right now, the only validation is :required,
        # which may be set to true. It defaults to false.
        # TODO: Should we restrict or validate the types that can be assigned via these accessors?
        #       Right now somebody can assign anything to a field, and it just might screw up later.
        def coral_member(name, options={})
          member = Member.new(name, options[:type], options[:validates])

          attr_accessor member.ruby_name

          @coral_members ||= {}
          @coral_members[member.ruby_name] = member
        end

        # A hash of ruby method name to Member objects representing each member and metadata about it such as its type.
        def coral_members
          @coral_members || {}
        end

        # Make sure the list of Coral members is inheritable. Note that this is a copy on create, so
        # you cannot add more members to the base class later and have them show up in the subclass.
        def inherited(subclass)
          subclass.instance_variable_set('@coral_members', coral_members.dup)
        end
      end

      # This is a simple data class for representing Coral members and handling some of their validation.
      class Member
        attr_reader :name, :ruby_name, :type, :validations

        def initialize(name, type, validations)
          @name = name.to_s
          @ruby_name = Support::Inflections.underscore(name)
          @type = type
          @validations = validations
        end

        def validate(value)
          return [] unless @validations

          errors = []

          # Make sure required members have a value
          if validations[:presence] == true && value.nil?
            errors << "#{ruby_name} is a required member"
          end

          # None of the rest of our validations matter if the value is nil
          return errors if value.nil?

          if validations[:inclusion] && !validations[:inclusion][:in].include?(value)
            errors << "#{ruby_name} must be one of #{validations[:inclusion][:in].join(', ')}"
          end

          if validations[:numericality] && validations[:numericality][:minimum] && value < validations[:numericality][:minimum]
            errors << "#{ruby_name} cannot be less than #{validations[:numericality][:minimum]}"
          end

          if validations[:numericality] && validations[:numericality][:maximum] && value > validations[:numericality][:maximum]
            errors << "#{ruby_name} cannot be greater than #{validations[:numericality][:maximum]}"
          end

          if validations[:length] && validations[:length][:minimum] && value.size < validations[:length][:minimum]
            if value.is_a?(String)
              errors << "#{ruby_name} cannot be shorter than #{validations[:length][:minimum]} characters"
            else
              errors << "#{ruby_name} cannot have less than #{validations[:length][:minimum]} elements"
            end
          end

          if validations[:length] && validations[:length][:maximum] && value.size > validations[:length][:maximum]
            if value.is_a?(String)
              errors << "#{ruby_name} cannot be longer than #{validations[:length][:maximum]} characters"
            else
              errors << "#{ruby_name} cannot have more than #{validations[:length][:maximum]} elements"
            end
          end

          if validations[:format] && validations[:format][:with] !~ value
            errors << "#{ruby_name} must match the regular expression #{validations[:format][:with]}"
          end

          errors
        end
      end
    end
  end
end

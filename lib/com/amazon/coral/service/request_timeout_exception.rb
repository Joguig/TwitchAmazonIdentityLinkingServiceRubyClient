require 'coral/exception'

module Com #:nodoc:
  module Amazon #:nodoc:
    module Coral #:nodoc:
      module Service
        # == Coral Exceptions
        #
        # Coral operation methods throw normal, typed exceptions.
        # Extra information can be retrieved through any Coral members on the exception.
        #
        # See the docs for Coral::Exception[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Exception.html] for more info.
        #
        #
        # == Examples
        #    
        #    begin
        #      result = my_client.my_operation(:param => 'bad')
        #    rescue Com::Amazon::Coral::Service::RequestTimeoutException=> e
        #      puts e.message
        #    end
        #
        class RequestTimeoutException < ::Coral::Exception
        end
      end
    end
  end
end


module Com #:nodoc:
  module Amazon #:nodoc:
    module Coral #:nodoc:
      module Service
        class RequestTimeoutException
          set_model_id 'com.amazon.coral.service#RequestTimeoutException'


          ##
          # :singleton-method: new
          # :call-seq:
          #   new(params)
          #
          # Construct a new RequestTimeoutException. Params can be passed in 
          # to specify the value of each member of the structure. If the type of a member is 
          # another structure, you can pass a hash in its place and that hash will be used to construct 
          # that structure, and so forth, or you can just provide your own instance of the structure.
          #
          # For example, you could initialize a MyStuffQuery structure in either of these ways:
          #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
          #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
          #


          ##
          # :method: message
          # :call-seq:
          #    message=(String)
          #    message -> String
          #
          # Accessor for the Message member of the structure. Contains a String.
          #
          coral_member :Message, :type => :String

        end
      end
    end
  end
end

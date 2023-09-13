require 'coral/structure'

module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      # == Coral Structures
      #
      # See the docs for Coral::Structure[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Structure.html] for more info about the properties of Structures.
      # Note that all the structure types used by a service class are automatically required when you require the service class,
      # so you don't usually have to require structure types explicitly.
      #
      #
      # == Examples
      #    require 'tv/justin/tails/o_auth_code_and_state'
      #    
      #    my_input = Tv::Justin::Tails::OAuthCodeAndState.new(:my_param => 'value')
      #
      class OAuthCodeAndState < ::Coral::Structure
      end
    end
  end
end


module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class OAuthCodeAndState
        set_model_id 'tv.justin.tails#OAuthCodeAndState'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new OAuthCodeAndState. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


        ##
        # :method: o_auth_code
        # :call-seq:
        #    o_auth_code=(String)
        #    o_auth_code -> String
        #
        # Accessor for the OAuthCode member of the structure. Contains a String.
        #
        # The value must be between 1 and 255 (inclusive) characters in length.
        coral_member :OAuthCode, :type => :String, :validates => { :length => { :maximum => 255, :minimum => 1 } }

        ##
        # :method: o_auth_state
        # :call-seq:
        #    o_auth_state=(String)
        #    o_auth_state -> String
        #
        # Accessor for the OAuthState member of the structure. Contains a String.
        #
        # The value must be between 1 and 255 (inclusive) characters in length.
        coral_member :OAuthState, :type => :String, :validates => { :length => { :maximum => 255, :minimum => 1 } }

      end
    end
  end
end

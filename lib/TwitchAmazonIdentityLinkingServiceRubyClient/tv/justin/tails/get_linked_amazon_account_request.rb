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
      #    require 'tv/justin/tails/get_linked_amazon_account_request'
      #    
      #    my_input = Tv::Justin::Tails::GetLinkedAmazonAccountRequest.new(:my_param => 'value')
      #
      class GetLinkedAmazonAccountRequest < ::Coral::Structure
      end
    end
  end
end


module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class GetLinkedAmazonAccountRequest
        set_model_id 'tv.justin.tails#GetLinkedAmazonAccountRequest'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new GetLinkedAmazonAccountRequest. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


        ##
        # :method: twitch_user_id
        # :call-seq:
        #    twitch_user_id=(String)
        #    twitch_user_id -> String
        #
        # Accessor for the TwitchUserId member of the structure. Contains a String.
        #
        # The value must be between 1 and 255 (inclusive) characters in length.
        # The value must match the regex /[0-9]+/.
        coral_member :TwitchUserId, :type => :String, :validates => { :length => { :maximum => 255, :minimum => 1 }, :format => { :with => /[0-9]+/ } }

      end
    end
  end
end

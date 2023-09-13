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
      #    require 'tv/justin/tails/get_linked_amazon_directed_id_response'
      #    
      #    my_input = Tv::Justin::Tails::GetLinkedAmazonDirectedIdResponse.new(:my_param => 'value')
      #
      class GetLinkedAmazonDirectedIdResponse < ::Coral::Structure
      end
    end
  end
end


module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class GetLinkedAmazonDirectedIdResponse
        set_model_id 'tv.justin.tails#GetLinkedAmazonDirectedIdResponse'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new GetLinkedAmazonDirectedIdResponse. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


        ##
        # :method: has_linked_account
        # :call-seq:
        #    has_linked_account=(Boolean)
        #    has_linked_account -> Boolean
        #
        # Accessor for the HasLinkedAccount member of the structure. Contains a Boolean.
        #
        coral_member :HasLinkedAccount, :type => :Boolean

        ##
        # :method: amazon_directed_id
        # :call-seq:
        #    amazon_directed_id=(String)
        #    amazon_directed_id -> String
        #
        # Accessor for the AmazonDirectedId member of the structure. Contains a String.
        #
        # The value must match the regex /amzn1\.account\.[A-Z2-7]{28}/.
        coral_member :AmazonDirectedId, :type => :String, :validates => { :format => { :with => /amzn1\.account\.[A-Z2-7]{28}/ } }

      end
    end
  end
end

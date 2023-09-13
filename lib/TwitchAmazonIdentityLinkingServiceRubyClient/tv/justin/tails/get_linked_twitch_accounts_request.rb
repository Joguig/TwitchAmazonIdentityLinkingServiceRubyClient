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
      #    require 'tv/justin/tails/get_linked_twitch_accounts_request'
      #    
      #    my_input = Tv::Justin::Tails::GetLinkedTwitchAccountsRequest.new(:my_param => 'value')
      #
      class GetLinkedTwitchAccountsRequest < ::Coral::Structure
      end
    end
  end
end

require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/amazon_account'

module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class GetLinkedTwitchAccountsRequest
        set_model_id 'tv.justin.tails#GetLinkedTwitchAccountsRequest'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new GetLinkedTwitchAccountsRequest. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


        ##
        # :method: amazon_account
        # :call-seq:
        #    amazon_account=(AmazonAccount)
        #    amazon_account -> AmazonAccount
        #
        # Accessor for the AmazonAccount member of the structure. Contains a AmazonAccount.
        #
        coral_member :AmazonAccount, :type => ::Tv::Justin::Tails::AmazonAccount

      end
    end
  end
end

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
      #    require 'tv/justin/tails/get_linked_twitch_accounts_response'
      #    
      #    my_input = Tv::Justin::Tails::GetLinkedTwitchAccountsResponse.new(:my_param => 'value')
      #
      class GetLinkedTwitchAccountsResponse < ::Coral::Structure
      end
    end
  end
end

require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/twitch_account'

module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class GetLinkedTwitchAccountsResponse
        set_model_id 'tv.justin.tails#GetLinkedTwitchAccountsResponse'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new GetLinkedTwitchAccountsResponse. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


        ##
        # :method: twitch_accounts
        # :call-seq:
        #    twitch_accounts=([ TwitchAccount ])
        #    twitch_accounts -> [ TwitchAccount ]
        #
        # Accessor for the TwitchAccounts member of the structure. Contains a list of TwitchAccount.
        #
        coral_member :TwitchAccounts, :type => [ ::Tv::Justin::Tails::TwitchAccount ]

      end
    end
  end
end

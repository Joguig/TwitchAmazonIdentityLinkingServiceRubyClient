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
      #    require 'tv/justin/tails/get_twitch_user_info_response'
      #    
      #    my_input = Tv::Justin::Tails::GetTwitchUserInfoResponse.new(:my_param => 'value')
      #
      class GetTwitchUserInfoResponse < ::Coral::Structure
      end
    end
  end
end

require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/twitch_account'

module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class GetTwitchUserInfoResponse
        set_model_id 'tv.justin.tails#GetTwitchUserInfoResponse'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new GetTwitchUserInfoResponse. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


        ##
        # :method: twitch_account
        # :call-seq:
        #    twitch_account=(TwitchAccount)
        #    twitch_account -> TwitchAccount
        #
        # Accessor for the TwitchAccount member of the structure. Contains a TwitchAccount.
        #
        coral_member :TwitchAccount, :type => ::Tv::Justin::Tails::TwitchAccount

      end
    end
  end
end

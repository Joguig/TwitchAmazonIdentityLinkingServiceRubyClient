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
      #    require 'tv/justin/tails/get_twitch_user_info_request'
      #    
      #    my_input = Tv::Justin::Tails::GetTwitchUserInfoRequest.new(:my_param => 'value')
      #
      class GetTwitchUserInfoRequest < ::Coral::Structure
      end
    end
  end
end

require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/o_auth_code_and_state'

module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class GetTwitchUserInfoRequest
        set_model_id 'tv.justin.tails#GetTwitchUserInfoRequest'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new GetTwitchUserInfoRequest. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


        ##
        # :method: o_auth_code_and_state
        # :call-seq:
        #    o_auth_code_and_state=(OAuthCodeAndState)
        #    o_auth_code_and_state -> OAuthCodeAndState
        #
        # Accessor for the OAuthCodeAndState member of the structure. Contains a OAuthCodeAndState.
        #
        coral_member :OAuthCodeAndState, :type => ::Tv::Justin::Tails::OAuthCodeAndState

      end
    end
  end
end

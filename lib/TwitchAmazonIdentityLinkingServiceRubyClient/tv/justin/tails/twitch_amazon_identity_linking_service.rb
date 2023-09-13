# :title: TwitchAmazonIdentityLinkingService Ruby Super Client
# :main: Tv::Justin::Tails::TwitchAmazonIdentityLinkingService
require 'coral/service'

require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/account_already_linked_exception'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/dependency_exception'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_linked_amazon_account_request'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_linked_amazon_account_response'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_linked_amazon_directed_id_request'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_linked_amazon_directed_id_response'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_linked_twitch_accounts_request'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_linked_twitch_accounts_response'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_twitch_user_info_request'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_twitch_user_info_response'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_twitch_user_name_request'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/get_twitch_user_name_response'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/invalid_parameter_exception'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/link_accounts_request'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/link_accounts_response'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/multiple_amazon_accounts_linked_exception'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/no_customer_info_found_exception'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/unlink_twitch_account_request'
require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/unlink_twitch_account_response'

module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      # A client interface for interacting with TwitchAmazonIdentityLinkingService.
      #
      # == Service Description
      #
      # A service that manages links between Amazon and Twitch Accounts.
      #
      # == Coral Clients
      #
      # The client presents a method for each operation on the service. Each method can take
      # an optional block argument that will be passed the underlying Coral::Call[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Call.html] object
      # to allow for cusomization of the call (such as adding identity information before the call is sent).
      #
      # Inputs to service methods can either be the declared input object, or an options hash that
      # could be used to construct the input object For example, if an operation takes a MyStuffQuery
      # that has two members, "foo" and "bar", you could call the operation in any of these ways:
      #    my_service.my_operation(
      #      MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), 
      #                       :bar => 'baz')
      #    )
      #
      #    my_service.my_operation(:foo => MyOtherStructure.new(:my_param => 'value'), 
      #                            :bar => 'baz')
      #
      #    my_service.my_operation(:foo => {
      #                              :my_param => 'value'
      #                            },
      #                            :bar => 'baz')
      # Hash inputs and real objects can be mixed at any level, just like when constructing the corresponding Coral::Structure[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Structure.html].
      # Service methods that have outputs produce real objects, and will throw real, typed exceptions in response to remote errors.
      # See the docs for Coral::Service[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Service.html] for more info.
      #
      # Requiring a service client also requires all types that the service uses - you don't need to require them again manually.
      #
      #
      # == Examples
      #    require 'tv/justin/tails/twitch_amazon_identity_linking_service'
      #    require 'coral/coral_rpc'
      #    
      #    my_client = Tv::Justin::Tails::TwitchAmazonIdentityLinkingService.new(Coral::CoralRPC.new_orchestrator(:endpoint => 'http://myservice.amazon.com'))
      #    
      #    # Just getting a result
      #    result = my_client.my_operation(:param => 'value')
      #    
      #    # Customizing the call before sending
      #    result = my_client.my_operation(:param => 'value') do |call|
      #      call.identity = foo
      #    end
      #
      class TwitchAmazonIdentityLinkingService < ::Coral::Service
        set_model_id 'tv.justin.tails#TwitchAmazonIdentityLinkingService'

        ##
        # :singleton-method: new
        # :call-seq:
        #   new(orchestrator)
        #
        # Construct a new client. Takes a Coral::Orchestrator[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Orchestrator.html] (for example, one returned by the
        # Coral::CoralRPC[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/CoralRPC.html]
        # class) through which to process requests.
        #
        # Example:
        #   my_client = Tv::Justin::Tails::TwitchAmazonIdentityLinkingService.new(Coral::CoralRPC.new_orchestrator(:endpoint => 'http://myservice.amazon.com'))
        #
        # Alternatively, you may pass an <tt>:endpoint</tt>
        # parameter (and an optional <tt>:timeout</tt>) and a default orchestrator will be chosen for you.
        # You must provide your own orchestrator if you need any more customization or if your service
        # doesn't support the default (currently CoralRPC).
        #
        # Example:
        #   my_client = Tv::Justin::Tails::TwitchAmazonIdentityLinkingService.new(:endpoint => 'http://myservice.amazon.com')


        ##
        # :method: get_twitch_user_info
        # :call-seq:
        #   get_twitch_user_info(GetTwitchUserInfoRequest){ |call| ... } -> GetTwitchUserInfoResponse
        #
        # Retrieves the Twitch login name and user ID for a user, given the OAuth code and state
        #
        # Calls the GetTwitchUserInfo operation. 
        # Takes a GetTwitchUserInfoRequest or an equivalent parameter hash as input. 
        # Returns a GetTwitchUserInfoResponse.
        # Can raise DependencyException.
        #
        coral_operation 'tv.justin.tails#GetTwitchUserInfo', :input => ::Tv::Justin::Tails::GetTwitchUserInfoRequest, :output => ::Tv::Justin::Tails::GetTwitchUserInfoResponse

        ##
        # :method: get_linked_amazon_directed_id
        # :call-seq:
        #   get_linked_amazon_directed_id(GetLinkedAmazonDirectedIdRequest){ |call| ... } -> GetLinkedAmazonDirectedIdResponse
        #
        # Get linked Amazon DirectedId from TwitchUserID.
        #
        # Calls the GetLinkedAmazonDirectedId operation. 
        # Takes a GetLinkedAmazonDirectedIdRequest or an equivalent parameter hash as input. 
        # Returns a GetLinkedAmazonDirectedIdResponse.
        # Can raise InvalidParameterException or DependencyException.
        #
        coral_operation 'tv.justin.tails#GetLinkedAmazonDirectedId', :input => ::Tv::Justin::Tails::GetLinkedAmazonDirectedIdRequest, :output => ::Tv::Justin::Tails::GetLinkedAmazonDirectedIdResponse

        ##
        # :method: get_twitch_user_name
        # :call-seq:
        #   get_twitch_user_name(GetTwitchUserNameRequest){ |call| ... } -> GetTwitchUserNameResponse
        #
        # Retrieves the Twitch user name given the Twitch user ID
        #
        # Calls the GetTwitchUserName operation. 
        # Takes a GetTwitchUserNameRequest or an equivalent parameter hash as input. 
        # Returns a GetTwitchUserNameResponse.
        # Can raise NoCustomerInfoFoundException or DependencyException.
        #
        coral_operation 'tv.justin.tails#GetTwitchUserName', :input => ::Tv::Justin::Tails::GetTwitchUserNameRequest, :output => ::Tv::Justin::Tails::GetTwitchUserNameResponse

        ##
        # :method: get_linked_twitch_accounts
        # :call-seq:
        #   get_linked_twitch_accounts(GetLinkedTwitchAccountsRequest){ |call| ... } -> GetLinkedTwitchAccountsResponse
        #
        # Get twitch linked accounts from amazon account
        #
        # Calls the GetLinkedTwitchAccounts operation. 
        # Takes a GetLinkedTwitchAccountsRequest or an equivalent parameter hash as input. 
        # Returns a GetLinkedTwitchAccountsResponse.
        # Can raise InvalidParameterException or DependencyException.
        #
        coral_operation 'tv.justin.tails#GetLinkedTwitchAccounts', :input => ::Tv::Justin::Tails::GetLinkedTwitchAccountsRequest, :output => ::Tv::Justin::Tails::GetLinkedTwitchAccountsResponse

        ##
        # :method: link_accounts
        # :call-seq:
        #   link_accounts(LinkAccountsRequest){ |call| ... } -> LinkAccountsResponse
        #
        # Link a twitch account to an amazon account.
        #
        # Calls the LinkAccounts operation. 
        # Takes a LinkAccountsRequest or an equivalent parameter hash as input. 
        # Returns a LinkAccountsResponse.
        # Can raise InvalidParameterException, AccountAlreadyLinkedException, DependencyException or MultipleAmazonAccountsLinkedException.
        #
        coral_operation 'tv.justin.tails#LinkAccounts', :input => ::Tv::Justin::Tails::LinkAccountsRequest, :output => ::Tv::Justin::Tails::LinkAccountsResponse

        ##
        # :method: unlink_twitch_account
        # :call-seq:
        #   unlink_twitch_account(UnlinkTwitchAccountRequest){ |call| ... } -> UnlinkTwitchAccountResponse
        #
        # Unlink a twitch account from its linked amazon account.
        #
        # Calls the UnlinkTwitchAccount operation. 
        # Takes a UnlinkTwitchAccountRequest or an equivalent parameter hash as input. 
        # Returns a UnlinkTwitchAccountResponse.
        # Can raise InvalidParameterException or DependencyException.
        #
        coral_operation 'tv.justin.tails#UnlinkTwitchAccount', :input => ::Tv::Justin::Tails::UnlinkTwitchAccountRequest, :output => ::Tv::Justin::Tails::UnlinkTwitchAccountResponse

        ##
        # :method: get_linked_amazon_account
        # :call-seq:
        #   get_linked_amazon_account(GetLinkedAmazonAccountRequest){ |call| ... } -> GetLinkedAmazonAccountResponse
        #
        # Get linked Amazon Account from TwitchUserID.
        #
        # Calls the GetLinkedAmazonAccount operation. 
        # Takes a GetLinkedAmazonAccountRequest or an equivalent parameter hash as input. 
        # Returns a GetLinkedAmazonAccountResponse.
        # Can raise NoCustomerInfoFoundException, InvalidParameterException or DependencyException.
        #
        coral_operation 'tv.justin.tails#GetLinkedAmazonAccount', :input => ::Tv::Justin::Tails::GetLinkedAmazonAccountRequest, :output => ::Tv::Justin::Tails::GetLinkedAmazonAccountResponse

      end
    end
  end
end

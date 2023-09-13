require "TwitchAmazonIdentityLinkingServiceRubyClient/version"
require "TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/twitch_amazon_identity_linking_service"
require "coral/coral_rpc"

module TwitchAmazonIdentityLinkingServiceRubyClient

  class ClientDriver
    def initialize(args)
        @client =Tv::Justin::Tails::TwitchAmazonIdentityLinkingService.new(
          Coral::CoralRPC.new_orchestrator({
            :endpoint => args[:end_point],
            :timeout => args[:timeout],
            :ca_file => args[:ca_path],
            :http_client_x509_key => args[:key],
            :http_client_x509_cert => args[:cert]
            }))
    end
  
    def unlink?(twitch_id)
        request = Tv::Justin::Tails::UnlinkTwitchAccountRequest.new(:twitch_user_id => twitch_id)
        results = @client.unlink_twitch_account(request)
        results.success
    end

    def has_linked_amazon?(twitch_id)
        request = Tv::Justin::Tails::GetLinkedAmazonDirectedIdRequest.new(:twitch_user_id => twitch_id)
        results = @client.get_linked_amazon_directed_id(request)
        results.has_linked_account
    end
  end
end

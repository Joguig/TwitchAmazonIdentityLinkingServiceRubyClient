require 'TwitchAmazonIdentityLinkingServiceRubyClient/tv/justin/tails/unrecoverable_exception'

module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      # == Exception Description
      #
      # This exception is thrown when trying to link an already linked Twitch account to another amazon account
      #
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
      #    rescue Tv::Justin::Tails::AccountAlreadyLinkedException=> e
      #      puts e.message
      #    end
      #
      class AccountAlreadyLinkedException < ::Tv::Justin::Tails::UnrecoverableException
      end
    end
  end
end


module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class AccountAlreadyLinkedException
        set_model_id 'tv.justin.tails#AccountAlreadyLinkedException'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new AccountAlreadyLinkedException. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


      end
    end
  end
end

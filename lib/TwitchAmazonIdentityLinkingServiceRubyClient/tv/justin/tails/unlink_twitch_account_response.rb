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
      #    require 'tv/justin/tails/unlink_twitch_account_response'
      #    
      #    my_input = Tv::Justin::Tails::UnlinkTwitchAccountResponse.new(:my_param => 'value')
      #
      class UnlinkTwitchAccountResponse < ::Coral::Structure
      end
    end
  end
end


module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class UnlinkTwitchAccountResponse
        set_model_id 'tv.justin.tails#UnlinkTwitchAccountResponse'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new UnlinkTwitchAccountResponse. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


        ##
        # :method: success
        # :call-seq:
        #    success=(Boolean)
        #    success -> Boolean
        #
        # Accessor for the Success member of the structure. Contains a Boolean.
        #
        coral_member :Success, :type => :Boolean

      end
    end
  end
end

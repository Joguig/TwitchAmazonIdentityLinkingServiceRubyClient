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
      #    require 'tv/justin/tails/public_amazon_account'
      #    
      #    my_input = Tv::Justin::Tails::PublicAmazonAccount.new(:my_param => 'value')
      #
      class PublicAmazonAccount < ::Coral::Structure
      end
    end
  end
end


module Tv #:nodoc:
  module Justin #:nodoc:
    module Tails
      class PublicAmazonAccount
        set_model_id 'tv.justin.tails#PublicAmazonAccount'


        ##
        # :singleton-method: new
        # :call-seq:
        #   new(params)
        #
        # Construct a new PublicAmazonAccount. Params can be passed in 
        # to specify the value of each member of the structure. If the type of a member is 
        # another structure, you can pass a hash in its place and that hash will be used to construct 
        # that structure, and so forth, or you can just provide your own instance of the structure.
        #
        # For example, you could initialize a MyStuffQuery structure in either of these ways:
        #    MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'), :bar => 'baz'))
        #    MyStuffQuery.new(:foo => { :my_param => 'value' }, :bar => 'baz')
        #


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

        ##
        # :method: amazon_name
        # :call-seq:
        #    amazon_name=(String)
        #    amazon_name -> String
        #
        # Accessor for the AmazonName member of the structure. Contains a String.
        #
        # The value must be greater than or equal to 1 characters in length.
        coral_member :AmazonName, :type => :String, :validates => { :length => { :minimum => 1 } }

        ##
        # :method: amazon_account_pool
        # :call-seq:
        #    amazon_account_pool=(String)
        #    amazon_account_pool -> String
        #
        # Accessor for the AmazonAccountPool member of the structure. Contains a String.
        #
        # The value must be one of "Amazon", "AmazonJP", "AmazonCN".
        coral_member :AmazonAccountPool, :type => :String, :validates => { :inclusion => { :in => [ %q!Amazon!, %q!AmazonJP!, %q!AmazonCN! ] } }

        ##
        # :method: amazon_email_address
        # :call-seq:
        #    amazon_email_address=(String)
        #    amazon_email_address -> String
        #
        # Accessor for the AmazonEmailAddress member of the structure. Contains a String.
        #
        # The value must be greater than or equal to 1 characters in length.
        coral_member :AmazonEmailAddress, :type => :String, :validates => { :length => { :minimum => 1 } }

        ##
        # :method: country_of_residence
        # :call-seq:
        #    country_of_residence=(String)
        #    country_of_residence -> String
        #
        # Accessor for the CountryOfResidence member of the structure. Contains a String.
        #
        # The value must be greater than or equal to 1 characters in length.
        coral_member :CountryOfResidence, :type => :String, :validates => { :length => { :minimum => 1 } }

        ##
        # :method: preferred_marketplace
        # :call-seq:
        #    preferred_marketplace=(String)
        #    preferred_marketplace -> String
        #
        # Accessor for the PreferredMarketplace member of the structure. Contains a String.
        #
        # The value must be greater than or equal to 1 characters in length.
        coral_member :PreferredMarketplace, :type => :String, :validates => { :length => { :minimum => 1 } }

      end
    end
  end
end

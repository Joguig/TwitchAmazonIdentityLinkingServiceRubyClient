module Coral
  module Support

    # Some of the inflections used by Rails' ActiveSupport::Inflector.
    # We use them to generate different identifiers for the Super Client.
    module Inflections

      #The reverse of camelize. Makes an underscored form from the expression in the string.
      #
      #Changes ’::’ to ’/’ to convert namespaces to paths.
      def self.underscore(camel_cased_word)
        camel_cased_word.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end
    end
  end
end

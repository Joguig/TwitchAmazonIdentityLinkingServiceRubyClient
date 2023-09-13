require 'coral/exception'

module Coral
  # UnknownErrorxception represents an exception that wasn't defined in the Coral model when
  # this client was generated, or where the service behaved in a totally unexpected manner,
  # such as returning no result at all.
  class UnknownException < Coral::Exception
  end
end

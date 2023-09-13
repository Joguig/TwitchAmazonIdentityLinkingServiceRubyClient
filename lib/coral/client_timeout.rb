require 'coral/exception'
require 'coral/client_error'

module Coral
  # ClientTimeout exceptions occur whenever the call to the service timed out.
  # Check inner_exception for more details.
  # ClientTimeouts are also ClientErrors, so they can be rescued together.
  class ClientTimeout < ClientError
  end
end

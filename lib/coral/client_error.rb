require 'coral/exception'

module Coral
  # ClientError represents a non-timeout exception raised by the client while trying to communicate
  # with the service. Check inner_exception for the original exception.
  class ClientError < StandardError
    # The nested exception that represents the actual error.
    attr_accessor :inner_exception

    def initialize(message, inner_exception)
      super("#{message}. Caused by #{inner_exception.to_s}")
      @inner_exception = inner_exception
    end
  end
end

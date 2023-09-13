module Coral

  # Internal abstraction that encapsulates the input and output data pertaining to a remote call.
  class Job
    # The hash of request attributes
    attr_reader :request

    # The hash of reply attributes
    attr_reader :reply

    #  Hash containing metrics
    attr_accessor :metrics

    def initialize(request)
      @request = request
      @reply = {}
      @metrics = {}
    end
  end

end


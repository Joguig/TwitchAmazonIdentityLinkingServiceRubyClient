require 'coral/job'
require 'coral/gat_handler'
require 'coral/support/logging'

module Coral
  #
  # Directs a Job through a Handler chain for processing.
  #
  # Copyright:: Copyright (c) 2008 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
  #
  class Orchestrator
    include Coral::Support::Logging

    # An array of handlers that will be executed for every request
    attr_accessor :handlers

    # Instantiate an orchestrator with the given list of Handlers.
    def initialize(handlers = [])
      @handlers = handlers
    end

    # Direct the specified request down the Handler chain, invoking first each before method,
    # then in reverse order each after method.  If any exceptions are thrown along the way, orchestration
    # will stop immediately, except for exceptions thrown by the GAT handlers, since they should not
    # alter the functionality.
    def orchestrate(request)
      logger.debug "Processing request #{request}"

      job = Job.new(request)

      handlers.each do |handler|
        handler.before(job)
      end

      handlers.reverse_each do |handler|
        handler.after(job)
      end

      return job.reply
    end

  end

end

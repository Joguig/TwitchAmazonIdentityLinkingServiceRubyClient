# :title: Coral Ruby Super Client Documentation

require 'coral/call'
require 'coral/support/inflections'
require 'coral/model_id'
require 'timeout'

module Coral

  # Coral::Service is the base class for all Super Client service clients. It provides a means for
  # describing Coral services, which produces a client class with methods for each operation that take and
  # return real objects, and throw typed exceptions.  Underneath, it's using the standard Ruby Coral client
  # orchestrators and dispatchers to actually make the calls.
  #
  # == Coral Services
  #
  # The client presents a method for each operation on the service. Each method can take
  # an optional block argument that will be passed the underlying
  # Amazon::Coral::Call[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubyClient-1.0/brazil-documentation/classes/Amazon/Coral/Call.html]
  # object to allow for cusomization of the call (such as adding identity information before the call is sent).
  #
  # Inputs to service methods can either be the declared input object, or an options hash that
  # could be used to construct the input object For example, if an operation takes a MyStuffQuery
  # that has two members, "foo" and "bar", you could call the operation in any of these ways:
  #    my_service.my_operation(
  #      MyStuffQuery.new(:foo => MyOtherStructure.new(:my_param => 'value'),
  #                       :bar => 'baz')
  #    )
  #
  #    my_service.my_operation(:foo => MyOtherStructure.new(:my_param => 'value'),
  #                            :bar => 'baz')
  #
  #    my_service.my_operation(:foo => {
  #                              :my_param => 'value'
  #                            },
  #                            :bar => 'baz')
  # Hash inputs and real objects can be mixed at any level, just like when constructing the corresponding
  # Coral::Structure[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/classes/Coral/Structure.html].
  #
  # Service methods that have outputs produce real objects, and will throw real, typed exceptions in response to remote errors.
  #
  # == Using a Service
  #    require 'coral/my_service'
  #    require 'amazon/coral/awsquery'
  #
  #    my_client = Coral::MyService::Service.new(Amazon::Coral::AwsQuery.new_orchestrator(:endpoint => 'http://myservice.amazon.com'))
  #
  #    # Just getting a result
  #    result = my_client.my_operation(:param => 'value')
  #
  #    # Customizing the call before sending
  #    result = my_client.my_operation(:param => 'value') do |call|
  #      call.identity = foo
  #    end
  #
  # == Defining Services
  #
  # Individual services are described using the set_model_id and coral_operation class methods. This allows service definitions
  # to be entirely descriptive, with implementation being generated at runtime. Each new service must set the model id of the service
  # by calling set_model_id its class definition. Then, each operation is defined with a call to coral_operation, giving its
  # name and input and output types (if it has any).
  #
  #
  # == Example Service Definition
  #
  #   class MyService < Coral::Service
  #     set_model_id 'com.amazon.myservice#MyService'
  #
  #     coral_operation :myOperation, :input => MyService::MyOperationInput, :output => MyService::MyOperationOutput
  #   end
  class Service
    extend HasModelId

    # The orchestrator that will handle communication with the service.
    attr_reader :orchestrator

    # Default options for the retry method (private class variable).
    @@RETRY_DEFAULT_OPTIONS = {
      :tries => 2,
      :backoff => :exponential,
      :on    => [
        ::Timeout::Error,
        ::Errno::ETIMEDOUT
      ]
    }.freeze

    # A simple class that contains information about a single service operation.
    # It's analgous to the Member object on Coral structures.
    class Operation
      attr_reader :coral_name, :ruby_name, :input_class, :output_class

      def initialize(coral_name, options = {})
        @coral_name = coral_name
        @ruby_name = Support::Inflections.underscore(::Coral::ModelId.new(coral_name).name)
        @input_class = options[:input]
        @output_class = options[:output]
      end
    end

    # A hash of the declared coral operations, indexed by their ruby name.
    def self.coral_operations
      @coral_operations ||= Hash.new
    end

    # Describe a single operation on a Coral service,
    # including its input/output types. It results in a
    # method that is named from the Rubyish, underscored version of the original camel-cased
    # Coral method name - for example, getPipelines becomes get_pipelines.
    #
    # The service method can be called in two ways:
    # * Normally, like service.get_pipelines - returns the result
    # * With a block, which gets passed the call object for customization before the call is sent.
    #
    # Typed exceptions will be thrown corresponding to the declared exception
    # types in the Coral model, or one of a generic set of Coral exceptions like
    # Coral::TimeoutException.
    #
    # coral_operation_name should be the fully qualified model id of the operation model, like "com.amazon.myservice#dbPing".
    def self.coral_operation(coral_operation_name, options={})
      ruby_operation_name = Support::Inflections.underscore(ModelId.new(coral_operation_name).name)

      has_output = options.has_key? :output
      output_type = options[:output].to_s if has_output
      has_input = options.has_key? :input
      input_type = options[:input].to_s if has_input

      # Add this operation to the coral_operations hash.
      coral_operations[ruby_operation_name] = Operation.new(coral_operation_name, options)

      # This is a lot to eval, especially with the messy trinary operators, but building up the string bit by bit
      # would make it much harder for exceptions thrown from within this code to point back to the line they were
      # declared in. We could also have the body of the generated method just be a call to a generic method
      # for processing operations, but I thought it was more fun to emit code that was specifically tailored to
      # the particular call instead of having just one generic method with a lot of conditionals that needed to be
      # evaluated each time it's called.
      class_eval  <<-CORAL_OP, __FILE__, __LINE__ + 1
        def #{ruby_operation_name}#{has_input ? '(params = {})' : ''}
          # Convert input into an object if it was an options hash
          #{has_input ? "params = params.is_a?(#{input_type}) ? params : #{input_type}.new(params)" : ''}

          # Validate the input object
          #{has_input ? 'validation_errors = params.validate' : ''}
          #{has_input ? 'raise ::ArgumentError.new(validation_errors.inspect) unless validation_errors.empty?' : ''}

          call = Coral::Call.new(self, '#{coral_operation_name}')

          # Let people customize the call with a block
          yield call if block_given?

          call.call#{has_input ? '(params)' : ''}
        end
      CORAL_OP
    end

    # Construct a new client.  Takes a Coral::Orchestrator (for example, one returned by the
    # Coral::CoralRPC class) through which to process requests.
    #
    # Example:
    #   my_client = Com::Amazon::MyService::MyService.new(Coral::CoralRPC.new_orchestrator(:endpoint => 'http://myservice.amazon.com'))
    #
    # Alternatively, you may pass an <tt>:endpoint</tt>
    # parameter (and an optional <tt>:timeout</tt>) and a default orchestrator will be chosen for you.
    # You must provide your own orchestrator if you need any more customization or if your service doesn't
    # support the default (currently CoralRPC).
    #
    # Example:
    #   my_client = Coral::MyService::Service.new(:endpoint => 'http://myservice.amazon.com')
    def initialize(orchestrator = {})
      # If we were passed an orchestrator
      if orchestrator.respond_to? :orchestrate
        @orchestrator = orchestrator
      elsif orchestrator.is_a?(Hash) && !orchestrator[:endpoint].nil?
        require 'coral/coral_rpc'

        # We only allow :endpoint and :timeout in hopes of keeping this default orchestrtor generic
        @orchestrator = Coral::CoralRPC.new_orchestrator(:endpoint => orchestrator[:endpoint], :timeout => orchestrator[:timeout])
      else
        raise "No orchestrator provided"
      end
    end

    # Retry execution of the block passed with random exponential backoff,
    # retrying on the specified errors for a given number of times.
    #
    # The default behaviour is to retry a single time on timeouts only:
    #
    # Example:
    #   my_client.retry do |client|
    #      client.call(:my_method, parameters)
    #   end
    #
    # You may override the number of attempts
    #
    # Example:
    #   my_client.retry(tries: 3) do |client|
    #      client.call(:my_method, parameters)
    #   end
    #
    # or the Exception class that will be retried on
    #
    # Example:
    #   my_client.retry(on: ArgumentError) do |client|
    #      client.call(:my_method, parameters)
    #   end
    #
    # Example:
    #   my_client.retry(on: [ArgumentError, StandardError]) do |client|
    #      client.call(:my_method, parameters)
    #   end
    #
    # or the backoff policy (linear, exponential or random)
    #
    # Example:
    #   my_client.retry(backoff: exponential) do |client|
    #      client.call(:my_method, parameters)
    #   end
    #
    # Example:
    #   my_client.retry(backoff: linear) do |client|
    #      client.call(:my_method, parameters)
    #   end
    def retry(options = {})
      fail ArgumentError, 'Needs a block.' unless block_given?

      opts = @@RETRY_DEFAULT_OPTIONS.merge(options)

      fail ArgumentError, 'tries must be positive' if opts[:tries] <= 0

      attempt = 0
      begin
        attempt += 1
        return yield self
      rescue *opts[:on] => error
        if (attempt) < opts[:tries]
          # Formula suggested in the AWS exponential backoff recommendations.
          backoff = get_backoff_time(attempt, opts[:backoff])
          sleep(backoff)
          retry
        else
          raise error
        end
      end
    end

    private

    # Computes the backoff time, in seconds, based on the policy.
    # The policy defaults to random, and the number of attempts default to 1
    #
    # Example (random backoff):
    #   self.get_backoff_time()
    #
    # Example (linear backoff):
    #   self.get_backoff_time(2, :linear)
    #
    # Example (exponential backoff):
    #   self.get_backoff_time(2, :exponential)
    def get_backoff_time(attempt = 1, policy = '')
      case policy
      when :exponential
        # exponential backoff
        rand(2**attempt * 100) / 1000.0
      when :linear
        # linear backoff
        rand(attempt * 100) / 1000.0
      else
        # random
        rand(100) / 1000.0
      end
    end
  end
end

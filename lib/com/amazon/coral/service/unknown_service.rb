# :title: UnknownService Ruby Super Client
# :main: Com::Amazon::Coral::Service::UnknownService
require 'coral/service'


module Com #:nodoc:
  module Amazon #:nodoc:
    module Coral #:nodoc:
      module Service
        # A client interface for interacting with UnknownService.
        #
        # == Coral Clients
        #
        # The client presents a method for each operation on the service. Each method can take
        # an optional block argument that will be passed the underlying Coral::Call[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Call.html] object
        # to allow for cusomization of the call (such as adding identity information before the call is sent).
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
        # Hash inputs and real objects can be mixed at any level, just like when constructing the corresponding Coral::Structure[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Structure.html].
        # Service methods that have outputs produce real objects, and will throw real, typed exceptions in response to remote errors.
        # See the docs for Coral::Service[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Service.html] for more info.
        #
        # Requiring a service client also requires all types that the service uses - you don't need to require them again manually.
        #
        #
        # == Examples
        #    require 'com/amazon/coral/service/unknown_service'
        #    require 'coral/coral_rpc'
        #    
        #    my_client = Com::Amazon::Coral::Service::UnknownService.new(Coral::CoralRPC.new_orchestrator(:endpoint => 'http://myservice.amazon.com'))
        #    
        #    # Just getting a result
        #    result = my_client.my_operation(:param => 'value')
        #    
        #    # Customizing the call before sending
        #    result = my_client.my_operation(:param => 'value') do |call|
        #      call.identity = foo
        #    end
        #
        class UnknownService < ::Coral::Service
          set_model_id 'com.amazon.coral.service#UnknownService'

          ##
          # :singleton-method: new
          # :call-seq:
          #   new(orchestrator)
          #
          # Construct a new client. Takes a Coral::Orchestrator[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/Orchestrator.html] (for example, one returned by the
          # Coral::CoralRPC[https://devcentral.amazon.com/ac/brazil/package-master/package/live/CoralRubySuperClient-1.0/brazil-documentation/Coral/CoralRPC.html]
          # class) through which to process requests.
          #
          # Example:
          #   my_client = Com::Amazon::Coral::Service::UnknownService.new(Coral::CoralRPC.new_orchestrator(:endpoint => 'http://myservice.amazon.com'))
          #
          # Alternatively, you may pass an <tt>:endpoint</tt>
          # parameter (and an optional <tt>:timeout</tt>) and a default orchestrator will be chosen for you.
          # You must provide your own orchestrator if you need any more customization or if your service
          # doesn't support the default (currently CoralRPC).
          #
          # Example:
          #   my_client = Com::Amazon::Coral::Service::UnknownService.new(:endpoint => 'http://myservice.amazon.com')


          ##
          # :method: unknown_operation
          # :call-seq:
          #   unknown_operation{ |call| ... }
          #
          # Calls the UnknownOperation operation. 
          #
          coral_operation 'com.amazon.coral.service#UnknownOperation'

        end
      end
    end
  end
end

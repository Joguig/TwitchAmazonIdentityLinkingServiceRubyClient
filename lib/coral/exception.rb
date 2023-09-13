require 'coral/support/structure_builder'

module Coral
  # A Coral::Exception describes an exception type from a service's Coral model. Each member of the structure
  # beyond the error message is described via a call to Coral::Support::StructureBuilder::ClassMethods#coral_member.
  # Besides acting as a normal exception, Coral::Exception types also behave like Coral structures. See
  # Coral::Support::StructureBuilder and Coral::Support::StructureBuilder::ClassMethods for more information
  # on the coral_member method and the methods available to structures.
  #
  # Typically, generated Coral exceptions follow a four-level heirarchy:
  #    MyService::MyException < MyService::Exception < Coral::Exception < StandardError
  # This allows additional functionality to be injected to all Coral exceptions, all exceptions from one
  # service, or a single exception. It also allows both general and fine-grained exception handling.
  class Exception < StandardError
    include Coral::Support::StructureBuilder
  end
end

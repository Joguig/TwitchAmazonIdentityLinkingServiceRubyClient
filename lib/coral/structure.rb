require 'coral/support/structure_builder'

module Coral
  # A Coral::Structure describes a datatype in a service's Coral model. Each member of the structure
  # is described via a call to Coral::Support::StructureBuilder::ClassMethods#coral_member. It
  # implements attributes for each of the type's members, as well as validations when Rails' ActiveModel::Validations
  # are present. The class supports being transformed to and from a hash to be used as input
  # to Coral service clients.
  #
  # Typically, generated Coral structures follow a three-level heirarchy:
  #    MyService::MyStructure < MyService::Structure < Coral::Structure
  # This allows additional functionality to be injected to all Coral types, all types from one
  # service, or a single type.
  #
  # See Coral::Support::StructureBuilder and Coral::Support::StructureBuilder::ClassMethods for more information
  # on the coral_member method and the methods available to Structures.
  class Structure
    include Coral::Support::StructureBuilder
  end
end

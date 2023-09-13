require 'coral/log_factory'

module Coral
  module Support
    # The Logging mixin provides a single method, "logger", which will get a Logger object initialized
    # with the class's name.
    module Logging
      def logger
        @log ||= LogFactory.getLog(self.class.name)
      end
    end
  end
end

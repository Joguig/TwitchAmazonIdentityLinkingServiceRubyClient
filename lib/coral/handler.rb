module Coral

  # Operates on a job before and after issuing the remote request.
  class Handler


    # Operate on the specified Job on the "outbound" side of the execution
    def before(job)
    end

    # Operation on the specified Job on the "inbound" side of the execution
    def after(job)
    end

  end

end

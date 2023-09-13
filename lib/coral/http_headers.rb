# A map for containing multivalued HTTP headers
# Note: Keys are case insensitive and will be returned in lower-case from
# the names, to_s, and to_hash methods. It is assumed that both keys and
# values are strings, though this is not enforced.
module Coral
  class HttpHeaders
    # Create a new headers instance, and optionally prefill it with the
    # supplied data. Note that the map keys should be strings, and the
    # values should be arrays of strings. These assumptions are not
    # enforced.
    def initialize(headers = {})
      @names = headers
    end
    def [](k)
      a = @names[k.downcase] or return nil
      return a.join(', ')
    end
    def []=(k, v)
      k = k.downcase
      unless v
        @names.delete k
        return v
      end
      @names[k] = [v]
    end
    def add_value(k, v)
      k = k.downcase
      if @names.key?(k)
        @names[k].push v
      else
        @names[k] = [v]
      end
    end
    def values(k)
      k = k.downcase
      @names[k]
    end
    def names
      @names.keys
    end
    def to_hash
      Hash[@names]
    end
    def to_s
      @names.to_s
    end
    def length
      @names.length
    end
    def size
      @names.size
    end
  end
end

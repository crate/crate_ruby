module CrateRuby
  class ResultSet
    include Enumerable

    attr_reader :rowcount, :duration, :cols, :rows

    # @param [String] Crate result
    def initialize(result)
      result = JSON.parse(result)
      @cols = result['cols']
      @rows = result  ['rows']
      @rowcount = result['rowcount']
      @duration = result['duration']
    end

    def <<(val)
      @rows << val
    end

    def each(&block)
      @rows.each(&block)
    end

    def [](val)
      @rows[val]
    end

  end
end
module CrateRuby
  class ResultSet
    include Enumerable

    attr_reader :rowcount, :duration, :cols

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
      nil
    end

    def [](val)
      @rows[val]
    end

    # @param [Array] ary Column names to filer on
    # @return [Array] Filtered rows
    def select_columns(ary, &block)
      indexes = ary.map {|col| @cols.index(col)}.compact
      @rows.map{|r| r.values_at(*indexes)}.each(&block)
    end

  end
end
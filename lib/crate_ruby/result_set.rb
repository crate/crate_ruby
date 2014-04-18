module CrateRuby
  class ResultSet
    include Enumerable

    attr_reader :rowcount, :duration, :cols

    # @param [String]  result
    def initialize(result)
      result = JSON.parse(result)
      @cols = result['cols']
      @rows = result['rows']
      @rowcount = result['rowcount']
      @duration = result['duration']
    end

    def inspect
      %Q{#<CrateRuby::ResultSet:#{object_id}>, @rowcount="#{@rowcount}", @duration=#{@duration}>}
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

    # @return [Array] Returns all rows as Array of arrays
    def values
      @rows
    end

    # @param [Array] ary Column names to filer on
    # @return [Array] Filtered rows
    def select_columns(ary, &block)
      indexes = ary.map {|col| @cols.index(col)}.compact
      @rows.map{|r| r.values_at(*indexes)}.each(&block)
    end

  end
end
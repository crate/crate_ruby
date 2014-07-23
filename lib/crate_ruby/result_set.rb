# -*- coding: utf-8; -*-
#
# Licensed to CRATE Technology GmbH ("Crate") under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  Crate licenses
# this file to you under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
# However, if you have executed another commercial license agreement
# with Crate these terms will supersede the license and you may use the
# software solely pursuant to the terms of the relevant commercial agreement.

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
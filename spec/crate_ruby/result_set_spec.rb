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

require_relative '../spec_helper'

describe ResultSet do
  let(:crate_result) { '{"cols":["my_column","my_integer_col"],"rows":[["Foo",5],["Bar",5]],"rowcount":1,"duration":4}' }
  let(:result_with_array_col) { %({"cols":["id","tags","title"],"rows":[[1,["awesome","freaky"],"My life with crate"]],"rowcount":1,"duration":2}) }
  let(:result_with_object) { %({"cols":["address","id","name"],"rows":[[{"street":"1010 W 2nd Ave","city":"Vancouver"},"fb7183ac-d049-462c-85a9-732aca59a1c1","Mad Max"]],"rowcount":1,"duration":3}) }

  let(:result_set) { ResultSet.new(crate_result) }

  let(:json_result) { JSON.parse crate_result }

  describe '#initialize' do
    it 'should set rowcount' do
      result_set.rowcount.should eq 1
    end

    it 'should set duration' do
      result_set.duration.should eq 4
    end

    it 'should set cols' do
      result_set.cols.should eq json_result['cols']
    end

    it 'should parse an array column result into an Array' do
      res = ResultSet.new(result_with_array_col)
      res[0][1].should be_a(Array)
      res[0][1].should eq(%w[awesome freaky])
    end

    it 'should parse an object column result into an Object' do
      res = ResultSet.new(result_with_object)
      res[0][0].should be_a(Hash)
      res[0][0].should eq('street' => '1010 W 2nd Ave', 'city' => 'Vancouver')
    end
  end

  describe '#each' do
    it 'should loop over the result rows' do
      result_set.each_with_index do |r, i|
        r.should eq json_result['rows'][i]
      end
    end
  end

  describe '#[]' do
    it 'should return the row at index' do
      result_set[1][0].should eq('Bar')
    end
  end

  describe '#values_at' do
    it 'should only return the columns specified' do
      a = []
      result_set.select_columns(['my_column']) do |res|
        a << res
      end
      a.should eq [['Foo'], ['Bar']]
    end
    it 'should not raise error on invalid column name' do
      expect do
        result_set.select_columns(%w[my_column invalid]) do |row|
        end
      end.to_not raise_error
    end
  end

  describe '#values' do
    it 'should return all rows as an array of arrays' do
      result_set.values.should eq json_result['rows']
    end
  end
end

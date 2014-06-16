require_relative '../spec_helper'

describe ResultSet do

  let(:crate_result) { "{\"cols\":[\"my_column\",\"my_integer_col\"],\"rows\":[[\"Foo\",5],[\"Bar\",5]],\"rowcount\":1,\"duration\":4}" }
  let(:result_with_array_col) { %Q{{"cols":["id","tags","title"],"rows":[[1,["awesome","freaky"],"My life with crate"]],"rowcount":1,"duration":2}} }

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
      res[0][1].should eq(["awesome","freaky"])
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
      a.should eq [["Foo"], ["Bar"]]

    end
    it 'should not raise error on invalid column name' do
      expect do
        result_set.select_columns(['my_column', 'invalid']) do |row|
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



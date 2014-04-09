require_relative '../spec_helper'

describe ResultSet do

  let(:crate_result) { "{\"cols\":[\"my_column\",\"my_integer_col\"],\"rows\":[[\"Foo\",5],[\"Bar\",5]],\"rowcount\":1,\"duration\":4}" }

  let(:result_set) { ResultSet.new(crate_result) }

  let(:json_result) { JSON.parse crate_result }

  describe '#initialize' do


    it 'should set rowcount' do
      result_set.rowcount.should eq 1
    end

    it 'should set duration' do
      result_set.duration.should eq 4
    end

    it 'should set rows' do
      result_set.rows.should eq json_result['rows']
    end

    it 'should set cols' do
      result_set.cols.should eq json_result['cols']
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

end



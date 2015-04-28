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

require_relative '../spec_helper'

describe CrateRuby::Client do

  before(:all) do
    @cluster = CrateRuby::TestCluster.new(1)
    @cluster.start_nodes
    @client = CrateRuby::Client.new(['localhost:44200'])
  end

  after(:all) do
    @cluster.stop_nodes
  end

  describe '#create_table' do

    describe 'blob management' do
      let(:file) { 'logo-crate.png' }
      let(:path) { File.join(File.dirname(__FILE__), '../uploads/') }
      let(:file_path) { File.join(path, file) }
      let(:digest) { Digest::SHA1.file(file_path).hexdigest }
      let(:store_location) { File.join(path, "get_#{file}") }

      before(:all) do
        @blob_table = 'my_blobs'
        @client.execute("create blob table #{@blob_table} clustered into 1 shards with (number_of_replicas=0)")
      end

      after(:all) do
        @client.execute("drop blob table #{@blob_table}")
      end

      describe '#blob_put' do
        context 'file' do
          it 'should upload a file to the blob table' do
            f = File.read(file_path)
            @client.blob_put(@blob_table, digest, f).should be_truthy
          end
        end
        context '#string' do
          let(:string) { "my crazy" }
          let(:digest) { Digest::SHA1.hexdigest(string) }
          it 'should upload a string to the blob table' do
            @client.blob_put(@blob_table, digest, string).should be_truthy
          end
        end
      end

      describe '#blob_get' do
        before do
          f = File.read(file_path)
          @client.blob_put(@blob_table, digest, f)
        end
        it 'should download a blob' do
          data = @client.blob_get(@blob_table, digest)
          data.should_not be_falsey
          open(store_location, "wb") { |file|
            file.write(data)
          }
        end
      end

      describe '#blob_delete' do
        before do
          f = File.read(file_path)
          @client.blob_put(@blob_table, digest, f)
        end
        it 'should delete a blob' do
          @client.blob_delete(@blob_table, digest)
        end
      end
    end


    describe '#execute' do
      let(:table_name) { "t_test" }

      before do
        @client.execute("create table #{table_name} (id integer primary key, name string, address object, tags array(string)) ")
      end

      after do
        @client.execute("drop table #{table_name}")
      end

      it 'should allow parameters' do
        @client.execute("insert into #{table_name} (id, name, address, tags) VALUES (?, ?, ?, ?)",
                       [1, "Post 1", {:street=>'1010 W 2nd Ave', :city=>'Vancouver'}, ['awesome', 'freaky']]).should be_truthy
        @client.refresh_table table_name
        @client.execute("select * from #{table_name}").rowcount.should eq(1)
      end

      it 'should allow bulk parameters' do
        bulk_args = [
          [1, "Post 1", {:street=>'1010 W 2nd Ave', :city=>'New York'}, ['foo','bar']],
          [2, "Post 2", {:street=>'1010 W 2nd Ave', :city=>'San Fran'}, []]
        ]
        @client.execute("insert into #{table_name} (id, name, address, tags) VALUES (?, ?, ?, ?)", nil, bulk_args).should be_truthy
        @client.refresh_table table_name
        @client.execute("select * from #{table_name}").rowcount.should eq(2)
        @client.execute("select count(*) from #{table_name}")[0][0].should eq(2)
      end

      it 'should accept http options' do
        expect { @client.execute("select * from #{table_name}", nil, nil, {'read_timeout'=>0}) }.to raise_error Net::ReadTimeout
      end
    end


    describe '#initialize' do
      it 'should use host and ports parameters' do
        logger = double()
        client = CrateRuby::Client.new ["10.0.0.1:4200"], logger: logger
        client.instance_variable_get(:@servers).should eq(["10.0.0.1:4200"])
      end
      it 'should use default request parameters' do
        client = CrateRuby::Client.new
        client.instance_variable_get(:@http_options).should eq({:read_timeout=>3600})
      end
      it 'should use request parameters' do
        client = CrateRuby::Client.new ['10.0.0.1:4200'],
            http_options: {:read_timeout=>60}
        client.instance_variable_get(:@http_options).should eq({:read_timeout=>60})
      end
    end

    describe '#tables' do
      before do
        @client.create_table "posts", id: :integer
        @client.create_table "comments", id: :integer
      end

      after do
        @client.tables.each do |table|
          @client.drop_table table
        end
      end

      it 'should return all user tables as an array of string values' do
        @client.tables.should eq ['posts', 'comments']
      end
    end


    describe '#insert' do
      before do
        @client.create_table("posts", id: [:string, "primary key"],
                             title: :string,
                             views: :integer)
      end

      after do
        @client.drop_table "posts"
      end

      it 'should insert the record' do
        expect do
          id = SecureRandom.uuid
          @client.insert('posts', id: id, title: "Test")
          @client.refresh_table('posts')
          result_set = @client.execute("Select * from posts where id = '#{id}'")
          result_set.rowcount.should eq 1
        end.not_to raise_exception
      end
    end

    describe '#refresh table' do
      it 'should issue the proper refresh statment' do
        @client.should_receive(:execute).with("refresh table posts")
        @client.refresh_table('posts')
      end
    end

  end
end

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
require 'securerandom'
require 'digest'

describe CrateRuby::Client do
  let(:client) { CrateRuby::Client.new(['localhost:44200']) }
  let(:client_w_schema) { CrateRuby::Client.new(['localhost:44200'], schema: 'custom') }

  describe '#create_table' do
    describe 'blob management' do
      let(:file) { 'logo-crate.png' }
      let(:path) { File.join(File.dirname(__FILE__), '../uploads/') }
      let(:file_path) { File.join(path, file) }
      let(:digest) { Digest::SHA1.file(file_path).hexdigest }
      let(:store_location) { File.join(path, "get_#{file}") }

      before do
        @blob_table = 'my_blobs'
        client.execute("create blob table #{@blob_table} clustered into 1 shards with (number_of_replicas=0)")
      end

      after do
        client.execute("drop blob table #{@blob_table}")
      end

      describe '#blob_put' do
        context 'file' do
          it 'should upload a file to the blob table' do
            f = File.read(file_path)
            expect(client.blob_put(@blob_table, digest, f)).to be_truthy
          end
        end
        context '#string' do
          let(:string) { 'my crazy' }
          let(:digest) { Digest::SHA1.hexdigest(string) }
          it 'should upload a string to the blob table' do
            expect(client.blob_put(@blob_table, digest, string)).to be_truthy
          end
        end
      end

      describe '#blob_get' do
        before do
          f = File.read(file_path)
          client.blob_put(@blob_table, digest, f)
        end
        it 'should download a blob' do
          data = client.blob_get(@blob_table, digest)
          expect(data).to be_truthy
          open(store_location, 'wb') do |file|
            file.write(data)
          end
        end
      end

      describe '#blob_delete' do
        before do
          f = File.read(file_path)
          client.blob_put(@blob_table, digest, f)
        end
        it 'should delete a blob' do
          client.blob_delete(@blob_table, digest)
        end
      end
    end

    describe '#execute' do
      let(:table_name) { 't_test' }

      before do
        client.execute("create table #{table_name} " \
           '(id integer primary key, name string, address object, tags array(string)) ')
      end

      after do
        client.execute("drop table #{table_name}")
      end

      it 'should allow parameters' do
        expect(client.execute("insert into #{table_name} (id, name, address, tags) VALUES (?, ?, ?, ?)",
                              [1, 'Post 1', { street: '1010 W 2nd Ave', city: 'Vancouver' },
                              %w[awesome freaky]])).to be_truthy
        client.refresh_table table_name
        expect(client.execute("select * from #{table_name}").rowcount).to eq(1)
      end

      it 'should allow bulk parameters' do
        bulk_args = [
          [1, 'Post 1', { street: '1010 W 2nd Ave', city: 'New York' }, %w[foo bar]],
          [2, 'Post 2', { street: '1010 W 2nd Ave', city: 'San Fran' }, []]
        ]
        expect(client.execute("insert into #{table_name} (id, name, address, tags) VALUES (?, ?, ?, ?)",
                              nil, bulk_args)).to be_truthy
        client.refresh_table table_name
        expect(client.execute("select * from #{table_name}").rowcount).to eq(2)
        expect(client.execute("select count(*) from #{table_name}")[0][0]).to eq(2)
      end

      it 'should accept http options' do
        expect do
          client.execute("select * from #{table_name}", nil, nil,
                         'read_timeout' => 0)
        end.to raise_error Net::ReadTimeout
      end

      context 'with schema' do
        before do
          client_w_schema.execute("create table #{table_name} \n
                 (id integer primary key, name string, address object, tags array(string)) ")
        end
        after { client_w_schema.execute("drop table #{table_name}") }

        it 'should allow parameters' do
          expect(client_w_schema.execute("insert into #{table_name} (id, name, address, tags) VALUES (?, ?, ?, ?)",
                                         [1, 'Post 1', { street: '1010 W 2nd Ave', city: 'Vancouver' },
                                         %w[awesome freaky]])).to be_truthy
          client_w_schema.refresh_table table_name
          expect(client.execute("select * from #{table_name}").rowcount).not_to eq(1)
          expect(client_w_schema.execute("select * from #{table_name}").rowcount).to eq(1)
        end
      end
    end

    describe '#initialize' do
      it 'should use host and ports parameters' do
        logger = double
        client = CrateRuby::Client.new ['10.0.0.1:4200'], logger: logger
        expect(client.instance_variable_get(:@servers)).to eq(['10.0.0.1:4200'])
      end
      it 'should use default request parameters' do
        client = CrateRuby::Client.new
        expect(client.instance_variable_get(:@http_options)).to eq(read_timeout: 3600)
      end
      it 'should use request parameters' do
        client = CrateRuby::Client.new ['10.0.0.1:4200'],
                                       http_options: { read_timeout: 60 }
        expect(client.instance_variable_get(:@http_options)).to eq(read_timeout: 60)
      end
    end

    describe '#tables' do
      before do
        client.create_table 'posts', id: :integer
        client.create_table 'comments', id: :integer
      end

      after do
        client.tables.each do |table|
          client.drop_table table
        end
      end

      it 'should return all user tables as an array of string values' do
        expect(client.tables).to eq %w[comments posts]
      end
    end

    describe '#blob_tables' do
      before do
        client.create_blob_table 'pix'
      end

      after do
        client.drop_table 'pix', true
      end

      it 'should return all user tables as an array of string values' do
        expect(client.blob_tables).to eq %w(pix)
      end
    end

    describe '#insert' do
      before do
        client.create_table('posts', id: [:string, 'primary key'],
                                     title: :string, views: :integer)
      end

      after do
        client.drop_table 'posts'
      end

      it 'should insert the record' do
        expect do
          id = SecureRandom.uuid
          client.insert('posts', id: id, title: 'Test')
          client.refresh_table('posts')
          result_set = client.execute("Select * from posts where id = '#{id}'")
          expect(result_set.rowcount).to eq 1
        end.not_to raise_exception
      end
    end

    describe '#refresh table' do
      it 'should issue the proper refresh statment' do
        expect(client).to receive(:execute).with('refresh table posts')
        client.refresh_table('posts')
      end
    end
  end

  describe 'authentication' do
    let(:username) { 'matz' }
    let(:password) { 'ruby' }
    let(:encrypted_credentials) { Base64.encode64 "#{username}:#{password}" }

    describe 'with password' do
      let(:auth_client) { CrateRuby::Client.new(['localhost:44200'], username: username, password: password) }
      it 'sets the basic auth header' do
        headers = auth_client.send(:headers)
        expect(headers['Authorization']).to eq "Basic #{encrypted_credentials}"
      end
    end

    describe 'without password' do
      let(:auth_client) { CrateRuby::Client.new(['localhost:44200'], username: username) }
      let(:enc_creds_wo_pwd) { Base64.encode64 "#{username}:" }

      it 'sets and encodes auth header even without password' do
        headers = auth_client.send(:headers)
        expect(headers['Authorization']).to eq "Basic #{enc_creds_wo_pwd}"
      end
    end

    describe 'X-User header' do
      let(:auth_client) { CrateRuby::Client.new(['localhost:44200'], username: username) }

      it 'sets the X-User header' do
        headers = auth_client.send(:headers)
        expect(headers['X-User']).to eq username
      end
    end
  end
end

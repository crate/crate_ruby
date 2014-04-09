require_relative '../spec_helper'

describe CrateRuby::Client do
  describe '#create_table' do
    let(:client) { CrateRuby::Client.new }

    describe 'blob mangament' do
      let(:table_name) { 'blob_table' }
      let(:file) { 'logo-crate.png' }
      #let(:file) { 'text.txt' }
      let(:path) { File.join(File.dirname(__FILE__), '../uploads/') }
      let(:file_path) { File.join(path, file) }
      let(:digest) { Digest::SHA1.file(file_path).hexdigest }
      let(:store_location) { File.join(path, "get_#{file}") }

      before do
        client.execute("create blob TABLE #{table_name}")
      end

      after do
        client.execute("drop blog TABLE #{table_name}")
      end

      describe '#blob_put' do

        after do
          client.blob_delete(table_name, digest)
        end

        context 'file' do

          it 'should upload a file to the blob table' do
            f = File.read(file_path)
            client.blob_put(table_name, digest, f).should be_true
          end
        end

        context '#string' do
          let(:string) {"my crazy"}
          let(:digest) {Digest::SHA1.hexdigest(string)}

          it 'should upload a string to the blob table' do
            client.blob_delete(table_name, digest)
            client.blob_put table_name, digest, string
          end
        end
      end

      describe '#blob_get' do

        before do
          f = File.read(file_path)
          client.blob_put(table_name, digest, f)
        end

        it 'should download a blob' do
          data = client.blob_get(table_name, digest)
          data.should_not be_false
          open(store_location, "wb") { |file|
            file.write(data)
          }
        end

        after do
          client.blob_delete(table_name, digest)
        end
      end

      describe '#blob_delete' do
        before do
          f = File.read(file_path)
          client.blob_put(table_name, digest, f)
        end

        it 'should delete a blob' do
          client.blob_delete(table_name, digest)
        end
      end
    end

    describe '#execute' do
      let(:table_name) { "post" }

      after do
        client.execute("drop TABLE #{table_name}").should be_true
      end

      it 'should create a new table' do
        client.execute("CREATE TABLE #{table_name} (id int)").should be_true
      end

    end


    describe '#initialize' do

      it 'should use host and ports parameters' do
        logger = double()
        client = CrateRuby::Client.new ["10.0.0.1:5000"],logger: logger
        client.instance_variable_get(:@servers).should eq(["10.0.0.1:5000"])
      end

    end

  end
end

require_relative '../spec_helper'

describe CrateRuby::Client do
  TABLE_NAME = 'blob_table'
  describe '#create_table' do
    let(:client) { CrateRuby::Client.new(["localhost:#{TEST_PORT}"]) }

    describe 'blob management' do
      let(:file) { 'logo-crate.png' }
      let(:path) { File.join(File.dirname(__FILE__), '../uploads/') }
      let(:file_path) { File.join(path, file) }
      let(:digest) { Digest::SHA1.file(file_path).hexdigest }
      let(:store_location) { File.join(path, "get_#{file}") }

      before(:all) do
        CrateRuby::Client.new(["localhost:#{TEST_PORT}"]).execute("create blob TABLE #{TABLE_NAME}")
      end

      after(:all) do
        CrateRuby::Client.new(["localhost:#{TEST_PORT}"]).execute("drop blob TABLE #{TABLE_NAME}")
      end

      describe '#blob_put' do

        after do
          client.blob_delete(TABLE_NAME, digest)
        end

        context 'file' do

          it 'should upload a file to the blob table' do
            f = File.read(file_path)
            client.blob_put(TABLE_NAME, digest, f).should be_true
          end
        end

        context '#string' do
          let(:string) { "my crazy" }
          let(:digest) { Digest::SHA1.hexdigest(string) }

          it 'should upload a string to the blob table' do
            client.blob_delete(TABLE_NAME, digest)
            client.blob_put TABLE_NAME, digest, string
          end
        end
      end

      describe '#blob_get' do

        before do
          f = File.read(file_path)
          client.blob_put(TABLE_NAME, digest, f)
        end

        it 'should download a blob' do
          data = client.blob_get(TABLE_NAME, digest)
          data.should_not be_false
          open(store_location, "wb") { |file|
            file.write(data)
          }
        end

        after do
          client.blob_delete(TABLE_NAME, digest)
        end
      end

      describe '#blob_delete' do
        before do
          f = File.read(file_path)
          client.blob_put(TABLE_NAME, digest, f)
        end

        it 'should delete a blob' do
          client.blob_delete(TABLE_NAME, digest)
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

      it 'should allow parameter substitution' do
        client.execute("CREATE TABLE #{table_name} (id int, title string, tags array(string) )").should be_true
        client.execute("INSERT INTO #{table_name} (id, title, tags) VALUES (\$1, \$2, \$3)",
                       [1, "My life with crate", ['awesome', 'freaky']]).should be_true
      end

    end


    describe '#initialize' do

      it 'should use host and ports parameters' do
        logger = double()
        client = CrateRuby::Client.new ["10.0.0.1:5000"], logger: logger
        client.instance_variable_get(:@servers).should eq(["10.0.0.1:5000"])
      end
    end

    describe '#tables' do
      before do
        client.create_table "posts", id: :integer
        client.create_table "comments", id: :integer
      end

      after do
        client.tables.each do |table|
          client.drop_table table
        end
      end

      it 'should return all user tables as an array of string values' do
        client.tables.should eq ['posts', 'comments']
      end
    end


    describe '#insert' do
      before do
        client.create_table("posts", id: [:string, "primary key"],
                            title: :string,
                            views: :integer)
      end

      after do
        client.drop_table "posts"
      end

      it 'should insert the record' do
        expect do
          id = SecureRandom.uuid
          client.insert('posts', id: id, title: "Test")
          client.refresh_table('posts')
          result_set = client.execute("Select * from posts where id = '#{id}'")
          result_set.rowcount.should eq 1
        end.not_to raise_exception
      end
    end

    describe '#refresh table' do
      it 'should issue the proper refresh statment' do
        client.should_receive(:execute).with("refresh table posts")
        client.refresh_table('posts')
      end
    end

  end
end

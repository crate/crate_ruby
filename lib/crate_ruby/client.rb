require 'json'
require 'net/http'
module CrateRuby
  class Client
    DEFAULT_HOST = "127.0.0.1"
    DEFAULT_PORT = "4200"

    attr_accessor :logger

    # Currently only a single server is supported. Fail over will be implemented in upcoming versions
    # @param [Array] servers An Array of servers including ports [127.0.0.1:4200, 10.0.0.1:4201]
    # @param [opts] Optional paramters
    # * logger: Custom Logger
    def initialize(servers = [], opts = {})
      @servers = servers
      @servers << "#{DEFAULT_HOST}:#{DEFAULT_PORT}" if servers.empty?
      @logger = opts[:logger] || CrateRuby.logger
    end

    def inspect
      %Q{#<CrateRuby::Client:#{object_id}>}
    end

    # Creates a table
    #     client.create_table "posts", id: [:integer, "primary key"], my_column: :string, my_integer_col: :integer
    # @param [String] table_name
    # @param [Hash] column_definition
    # @option column_definition [String] key sets column name, value sets column type. an array passed as value can be used to set options like primary keys
    # @return [Boolean]
    #
    def create_table(table_name, column_definition = {}, blob=false)
      cols = column_definition.to_a.map { |a| a.join(' ') }.join(', ')
      stmt = %Q{CREATE TABLE "#{table_name}" (#{cols})}
      execute(stmt)
    end

    # Creates a table for storing blobs
    # @param [String] name Table name
    # @param [Integer] shard Shard count, defaults to 5
    # @param [Integer] number Number of replicas, defaults to 0
    # @return [Boolean]
    #
    # client.create_blob_table("blob_table")
    def create_blob_table(name, shard_count=5, replicas=0)
      stmt = "create blob table #{name} clustered into #{shard_count} shards with (number_of_replicas=#{replicas})"
      execute stmt
    end

    # Drop table
    # @param [String] table_name, Name of table to drop
    # @param [Boolean] blob Needs to be set to true if table is a blob table
    # @return [Boolean]
    def drop_table(table_name, blob=false)
      tbl = blob ? "BLOB TABLE" : "TABLE"
      stmt = %Q{DROP #{tbl} "#{table_name}"}
      execute(stmt)
    end

    # List all user tables
    # @return [ResultSet]
    def show_tables
      execute("select table_name from information_schema.tables where schema_name = 'doc'")
    end

    # Returns all tables in schema 'doc'
    # @return [Array] Array of table names
    def tables
      execute("select table_name from information_schema.tables where schema_name = 'doc'").map(&:first)
    end

    # Executes a SQL statement against the Crate HTTP REST endpoint.
    # @param [String] sql statement to execute
    # @return [ResultSet, false]
    def execute(sql)
      @logger.debug sql
      req = Net::HTTP::Post.new("/_sql", initheader = {'Content-Type' => 'application/json'})
      req.body = {"stmt" => sql}.to_json
      response = request(req)
      @logger.debug response.body
      success = case response.code
                  when /^2\d{2}/
                    ResultSet.new response.body
                  else
                    @logger.info(response.body)
                    raise CrateRuby::CrateError.new(response.body)
                    false
                end
      success
    end

    # Upload a File to a blob table
    # @param [String] table
    # @param [String] digest SHA1 hexdigest
    # @param [Boolean] data Can be any payload object that can be sent via HTTP, e.g. STRING, FILE
    def blob_put(table, digest, data)
      uri = blob_path(table, digest)
      @logger.debug("BLOB PUT #{uri}")
      req = Net::HTTP::Put.new(blob_path(table, digest))
      req.body = data
      response = request(req)
      success = case response.code
                  when "201"
                    true
                  else
                    @logger.info("Response #{response.code}: " + response.body)
                    false
                end
      success
    end

    # Download blob
    # @param [String] table
    # @param [String] digest SHA1 hexdigest
    #
    # @return [Blob] File data to write to file or use directly
    def blob_get(table, digest)
      uri = blob_path(table, digest)
      @logger.debug("BLOB GET #{uri}")
      req = Net::HTTP::Get.new(uri)
      response = request(req)
      case response.code
        when "200"
          response.body
        else
          @logger.info("Response #{response.code}: #{response.body}")
          false
      end
    end

    # Delete blob
    # @param [String] table
    # @param [String] digest SHA1 hexdigest
    #
    # @return [Boolean]
    def blob_delete(table, digest)
      uri = blob_path(table, digest)
      @logger.debug("BLOB DELETE #{uri}")
      req = Net::HTTP::Delete.new(uri)
      response = request(req)
      success = case response.code
                  when "200"
                    true
                  else
                    @logger.info("Response #{response.code}: #{response.body}")
                    false
                end
      success
    end


    # Return the table structure
    # @param [String] table_name Table name to get structure
    # @param [ResultSet]
    def table_structure(table_name)
      execute("select * from information_schema.columns where schema_name = 'doc' AND table_name = '#{table_name}'")
    end


    def insert(table_name, attributes) #:nodoc:#
      vals = attributes.values.map {|x| x.is_a?(String) ? "'#{x}'" : x}.join(', ')
      stmt = %Q{INSERT INTO "#{table_name}" (#{attributes.keys.join(', ')}) VALUES (#{vals})}
      execute(stmt)
    end

    # Crate is eventually consistent, If you don't query by primary key,
    # it is not guaranteed that an insert record is found on the next
    # query. Default refresh value is 1000ms.
    # Using refresh_table you can force a refresh
    # @param [String] table_name Name of table to refresh
    def refresh_table(table_name)
      execute "refresh table #{table_name}"
    end

    private

    def blob_path(table, digest)
      "/_blobs/#{table}/#{digest}"
    end

    def connection
      host, port = @servers.first.split(':');
      Net::HTTP.new(host, port)
    end

    def request(req)
      connection.start { |http| http.request(req) }
    end

  end
end
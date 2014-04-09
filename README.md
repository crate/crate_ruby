# CrateRuby

Official ruby library to access a (Crate)[http://crate.io] database.

## Installation

Add this line to your application's Gemfile:

    gem 'crate_ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crate_ruby

## Usage

### Issueing SQL statements

    # optional args :host, :port, :logger
    client = CrateRuby::Client.new
    result = client.execute("Select * from posts")
     => #<CrateRuby::ResultSet:0x00000002a9c5e8 @cols=["id", "my_column", "my_integer_col"], @rows=[[1, "test", 5]], @rowcount=1, @duration=5>
    result.each do |row|
      puts row.inspect # [1, "test", 5]
    end

    result.cols
     => ["id", "my_column", "my_integer_col"]

### Up/Downloading data
    digest = Digest::SHA1.file(file_path).hexdigest

    #upload
    f = File.read(file_path)
    client.blob_put(table_name, digest, f)

    #download
    data = client.blob_get(table_name, digest)
    open(file_path, "wb") do |file|
      file.write(data)
    end

    #deletion
    client.blob_delete(table_name, digest)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/crate_ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add some tests
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

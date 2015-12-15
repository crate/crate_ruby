[![Gem Version](https://badge.fury.io/rb/crate_ruby.svg)](http://badge.fury.io/rb/crate_ruby)
[![Build Status](https://travis-ci.org/crate/crate_ruby.svg?branch=master)](https://travis-ci.org/crate/crate_ruby)
[![Code Climate](https://codeclimate.com/github/crate/crate_ruby.png)](https://codeclimate.com/github/crate/crate_ruby)


# CrateRuby

Official Ruby library to access the [Crate.IO](http://crate.io) database.

## Installation

This gem requires Ruby 2.0 or greater.

Add this line to your application's Gemfile:

    gem 'crate_ruby'

Or install it yourself as:

    $ gem install crate_ruby

## Usage

### Issuing SQL statements

    require 'crate_ruby'

    client = CrateRuby::Client.new

    result = client.execute("Select * from posts")
     => #<CrateRuby::ResultSet:0x00000002a9c5e8 @rowcount=1, @duration=5>

    result.each do |row|
      puts row.inspect
    end
     => [1, "test", 5]

    result.cols
     => ["id", "my_column", "my_integer_col"]


#### Using parameter substitution

     client.execute("INSERT INTO posts (id, title, tags) VALUES (\$1, \$2, \$3)",
                     [1, "My life with crate", ['awesome', 'freaky']])

### Up/Downloading data

    digest = Digest::SHA1.file(file_path).hexdigest

    # upload
    f = File.read(file_path)
    client.blob_put(table_name, digest, f)

    # download
    data = client.blob_get(table_name, digest)
    open(file_path, "wb") do |file|
      file.write(data)
    end

    # deletion
    client.blob_delete(table_name, digest)

## Tests

First, download and install Crate locally:

    ruby spec/bootstrap.rb

Then run tests with:

    bundle exec rspec spec

## Contributing

If you think something is missing, either create a pull request
or log a new issue, so someone else can tackle it.
Please refer to CONTRIBUTING.rst for further information.

## Maintainer

* [CRATE Technology GmbH](http://crate.io)
* [Christoph Klocker](http://www.vedanova.com), [@corck](http://www.twitter.com/corck)

## License & Copyright

See LICENSE for details.

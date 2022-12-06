###################
CrateDB Ruby Client
###################

.. image:: https://github.com/crate/crate_ruby/workflows/Tests/badge.svg
   :target: https://github.com/crate/crate_ruby/actions?workflow=Tests
   :alt: Build Status

.. image:: https://badge.fury.io/rb/crate_ruby.svg
   :target: https://rubygems.org/gems/crate_ruby
   :alt: Gem Version

.. image:: https://badgen.net/rubygems/dt/crate_ruby
   :target: https://rubygems.org/gems/crate_ruby
   :alt: Total downloads


|

A Ruby client library for the CrateDB HTTP interface.

- Query execution support.
- DDL command and schema introspection shortcuts.
- Support for BLOB tables.
- Foundation for the `activerecord-crate-adapter`_.


*************
Prerequisites
*************

You will need Ruby 2.0 or greater.


************
Installation
************

The CrateDB Ruby client is available on RubyGems.org, see `crate_ruby on RubyGems.org`_.

To use it, add this line to your application's ``Gemfile``::

    gem 'crate_ruby'

Or install it manually::

    gem install crate_ruby


********
Synopsis
********

Set up the client.

.. code:: ruby

    require 'crate_ruby'

    client = CrateRuby::Client.new()

Execute SQL queries.

.. code:: ruby

    result = client.execute("SELECT * FROM posts")
     => #<CrateRuby::ResultSet:0x00000002a9c5e8 @rowcount=1, @duration=5>

    result.each do |row|
      puts row.inspect
    end
     => [1, "test", 5]

    result.cols
     => ["id", "my_column", "my_integer_col"]


Perform parameter substitution.

.. code:: ruby

     client.execute(
         "INSERT INTO posts (id, title, tags) VALUES (\$1, \$2, \$3)",
         [1, "My life with crate", ['awesome', 'cool']])

Manipulate BLOBs.

.. code:: ruby

    require 'digest'

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

A default schema can be set by passing in the schema name.

.. code:: ruby

    CrateRuby::Client.new(['localhost:4200'], schema: 'my_schema')

Authentication credentials can be passed to the client if needed.

.. code:: ruby

    CrateRuby::Client.new(['localhost:4200'], username: 'foo', password: 'supersecret')

SSL can be enabled.

.. code:: ruby

    CrateRuby::Client.new(['localhost:4200'], ssl: true)


*****
Notes
*****

See also `CrateDB examples for Ruby`_ for a basic example program, which
exercises both the `crate_ruby`_ driver, as well as Ruby's canonical `pg`_
driver.


************
Contributing
************

This project is primarily maintained by `Crate.IO GmbH`_,
but we welcome community contributions!

See the `developer docs`_ and the `contribution docs`_ for more information.


****
Help
****

Looking for more help?

- Check out our `support channels`_


.. _activerecord-crate-adapter: https://github.com/crate/activerecord-crate-adapter
.. _contribution docs: CONTRIBUTING.rst
.. _Crate.IO GmbH: https://crate.io
.. _CrateDB: https://github.com/crate/crate
.. _CrateDB examples for Ruby: https://github.com/crate/cratedb-examples/tree/main/by-language/ruby
.. _crate_ruby: https://rubygems.org/gems/crate_ruby
.. _crate_ruby on RubyGems.org: https://rubygems.org/gems/crate_ruby
.. _developer docs: DEVELOP.rst
.. _gem: https://rubygems.org/
.. _pg: https://rubygems.org/gems/pg
.. _support channels: https://crate.io/support/

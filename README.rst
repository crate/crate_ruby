===================
CrateDB Ruby Client
===================

.. image:: https://badge.fury.io/rb/crate_ruby.svg
   :target: http://badge.fury.io/rb/crate_ruby
   :alt: Gem Version

.. image:: https://travis-ci.org/crate/crate_ruby.svg?branch=master
   :target: https://travis-ci.org/crate/crate_ruby
   :alt: Build Status

.. image:: https://codeclimate.com/github/crate/crate_ruby.png
   :target: https://codeclimate.com/github/crate/crate_ruby
   :alt: Code Climate

|

A Ruby client library for CrateDB_.

Prerequisites
=============

You will need Ruby 2.0 or greater.

Installation
============

The CrateDB Ruby client is available as a Ruby gem_.

Add this line to your application's ``Gemfile``::

    gem 'crate_ruby'

Or, install it manually, like so::

    $ gem install crate_ruby

Examples
========

Set up the client like so::

    require 'crate_ruby'

    client = CrateRuby::Client.new

Execute SQL queries like so::

    result = client.execute("Select * from posts")
     => #<CrateRuby::ResultSet:0x00000002a9c5e8 @rowcount=1, @duration=5>

    result.each do |row|
      puts row.inspect
    end
     => [1, "test", 5]

    result.cols
     => ["id", "my_column", "my_integer_col"]


Perform parameter substitution like so::

     client.execute(
         "INSERT INTO posts (id, title, tags) VALUES (\$1, \$2, \$3)",
         [1, "My life with crate", ['awesome', 'cool']])

Manipulate BLOBs like so::

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

Contributing
============

This project is primarily maintained by `Crate.io`_, but we welcome community
contributions!

See the `developer docs`_ and the `contribution docs`_ for more information.

Help
====

Looking for more help?

- Check `StackOverflow`_ for common problems
- Chat with us on `Slack`_
- Get `paid support`_

.. _contribution docs: CONTRIBUTING.rst
.. _Crate.io: https://crate.io
.. _CrateDB: https://github.com/crate/crate
.. _developer docs: DEVELOP.rst
.. _gem: https://rubygems.org/
.. _paid support: https://crate.io/pricing/
.. _Slack: https://crate.io/docs/support/slackin/
.. _StackOverflow: https://stackoverflow.com/tags/crate

===============
Developer Guide
===============

Tests
=====

First, download and install CrateDB locally::

    $ ruby spec/bootstrap.rb

Then, run tests like so::

    $ bundle exec rspec spec

Preparing a Release
===================

To create a new release, you must:

- Update ``CrateRuby.version`` in ``lib/crate_ruby/version.rb``

- Add a section for the new version in the ``history.txt`` file

- Commit your changes with a message like "prepare release x.y.z"

- Push to origin

- Create a tag by running ``./devtools/create_tag.sh``

RubyGems Deployment
===================

Update your package manager::

    $ gem update --system

Build the new gem::

    $ gem build crate_ruby.gemspec

Publish the new gem::

    $ gem push crate_ruby-<VERISON>.gem

Here, ``<VERISON>`` is the version you are releasing.

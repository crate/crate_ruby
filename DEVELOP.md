# Release Process

Business as usual, but in case you forgot, here it is.

* update ``CrateRuby.version`` in ``lib/crate_ruby/version.rb``
* update history.txt to reflect the changes of this release
* Do the traditional trinity of:

```ruby
gem update --system
gem build crate_ruby.gemspec
gem push crate_ruby-<version>.gem
```

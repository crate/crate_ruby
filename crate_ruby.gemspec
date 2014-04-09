# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crate_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "crate_ruby"
  spec.version       = CrateRuby::VERSION
  spec.authors       = ["Christoph Klocker"]
  spec.email         = ["christoph@vedanova.com"]
  spec.summary       = "A simple interface to Crate Data, a high performance database."
  spec.description   = ""
  spec.source        = "https://github.com/crate/crate-ruby"
  spec.homepage      = "http://crate.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
end

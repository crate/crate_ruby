# frozen_string_literal: true

#
# Licensed to Crate.IO GmbH ("Crate") under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  Crate licenses
# this file to you under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
# However, if you have executed another commercial license agreement
# with Crate these terms will supersede the license and you may use the
# software solely pursuant to the terms of the relevant commercial agreement.

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crate_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'crate_ruby'
  spec.version       = CrateRuby::VERSION
  spec.authors       = ['Christoph Klocker', 'Crate.IO GmbH']
  spec.email         = ['office@crate.io']
  spec.summary       = 'CrateDB HTTP client library for Ruby'
  spec.description   = 'A Ruby library for the CrateDB HTTP interface with query support, DDL command and schema introspection shortcuts, and support for BLOB tables.'
  spec.homepage      = 'https://crate.io'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = '>= 2.4'

  spec.files         = Dir['lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]
  spec.extra_rdoc_files = Dir['README.rst', 'CHANGES.rst', 'LICENSE', 'NOTICE']
  spec.rdoc_options    += [
    '--title', 'CrateDB HTTP client library for Ruby',
    '--main', 'README.rst',
    '--line-numbers',
    '--inline-source',
    '--quiet'
  ]

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/crate/crate_ruby/issues',
    'changelog_uri' => 'https://github.com/crate/crate_ruby/blob/main/CHANGES.rst',
    'documentation_uri' => 'https://www.rubydoc.info/gems/crate_ruby',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/crate/crate_ruby'
  }

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'os'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '< 1.13'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
end

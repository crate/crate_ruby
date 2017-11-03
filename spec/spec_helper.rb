#
# Licensed to CRATE Technology GmbH ("Crate") under one or more contributor
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

require_relative '../lib/crate_ruby'
require 'net/http'
require_relative 'support/test_cluster'

HOST = '127.0.0.1'.freeze
PORT = 44_200

RSpec.configure do |config|
  config.before(:each) do
  end
  config.after(:each) do
  end
  config.before(:suite) do
    @cluster = TestCluster.new(1, PORT)
    @cluster.start_nodes
  end
  config.after(:suite) do
    pid_file = File.join(__dir__, 'support/testnode.pid')
    pid = File.read(pid_file)
    File.delete(pid_file)
    Process.kill('HUP', pid.to_i)
  end
end

# -*- coding: utf-8; -*-
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

require 'net/http'
class TestServer
  CRATE_PATH = "~/crate"
  TEST_PORT = 4209
  NAME = "TestCluster"


  def initialize(crate_home = nil, port = nil, host = "127.0.0.1")
    @crate_home = crate_home || CRATE_PATH
    @port = port || TEST_PORT
    @host = host
  end

  def start
    cmd = "sh #{CRATE_PATH}/bin/crate #{start_params}"
    @pid = spawn(cmd, :out => "/tmp/crate_test_server.out", :err => "/tmp/crate_test_server.err")
    Process.detach(@pid)
    puts 'starting'
    time_slept = 0
    while true
      puts "Crate not yet fully available. Waiting since #{time_slept} seconds..." unless alive?
      sleep(2)
      time_slept += 2
    end
  end

  def stop
    Process.kill("HUP", @pid)
  end

  private


  def crate_exec
  end

  def crate_config
  end

  def start_params
    "-Des.index.storage.type=memory " +
        "-Des.node.name=#{NAME} " +
        "-Des.cluster.name=Testing#{@port} " +
        "-Des.http.port=#{@port}-#{@port} " +
        "-Des.network.host=localhost " +
        "-Des.discovery.type=zen " +
        "-Des.discovery.zen.ping.multicast.enabled=false"
  end

  def alive?
    req = Net::HTTP::Get.new('/')
    resp = Net::HTTP.new(@host, @port)
    begin
      response = resp.start { |http| http.request(req) }
      response.code == "200" ? true : false
    rescue Errno::ECONNREFUSED
      false
    end
  end

end

server = TestServer.new.start *ARGV

trap("INT") do
  puts "Script terminated by user."
  server.stop
  puts "Server stopped"
  exit
end
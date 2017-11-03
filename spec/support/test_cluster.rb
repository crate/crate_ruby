#!/usr/bin/env ruby
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

class TestCluster

  def initialize(num_nodes = 1, http_port=44200)
    @nodes = []
    idx = 0
    while idx < num_nodes do
      name = "crate#{idx-1}"
      port = http_port + idx
      @nodes << TestServer.new(name, port)
      idx += 1
    end
  end

  def start_nodes
    @nodes.each do |node|
      node.start
    end
  end

  def stop_nodes
    @nodes.each do |node|
      node.stop
    end
  end

end

class TestServer

  STARTUP_TIMEOUT = 30

  def initialize(name, http_port)
    @node_name = name
    @http_port = http_port

    @crate_bin = File.join('parts', 'crate', 'bin', 'crate')
    if !File.file?(@crate_bin)
      puts "Crate is not available. Please run 'bundle exec ruby spec/bootstrap.rb' first."
      exit 1
    end
  end

  def start
    cmd = "sh #{@crate_bin} #{start_params}"
    @pid = spawn(cmd)
    wait_for
    Process.detach(@pid)

    File.write(__dir__ + "/testnode.pid", @pid)
  end

  def wait_for
    time_slept = 0
    interval = 1
    while true
      if !alive? and time_slept > STARTUP_TIMEOUT
        puts "Crate hasn't started for #{STARTUP_TIMEOUT} seconds. Giving up now..."
        exit 1
      end
      if alive?
        break
      else
        sleep(interval)
        time_slept += interval
      end
    end
  end

  def stop
    Process.kill('HUP', @pid)
  end

  private

  def start_params
    "-Cnode.name=#{@node_name} " +
      "-Chttp.port=#{@http_port} " +
      "-Cnetwork.host=localhost "
  end

  def alive?
    req = Net::HTTP::Get.new('/')
    resp = Net::HTTP.new('localhost', @http_port)
    begin
      response = resp.start { |http| http.request(req) }
      response.code == "200" ? true : false
    rescue Errno::ECONNREFUSED
      false
    end
  end
end

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

require 'rubygems/package'
require 'net/http'
require 'zlib'

class Bootstrap

  VERSION = '2.1.8'

  def initialize
    @fname = "crate-#{VERSION}.tar.gz"
    @crate_bin = File.join('parts', 'crate' 'bin', 'crate')
  end

  def run
    if !File.file?(@crate_bin)
      if !File.file?(@fname)
        download
      end
      extract
    end
  end

  def download
    uri = URI("https://cdn.crate.io/downloads/releases/#{@fname}")
    puts "Downloading Crate from #{uri} ..."
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      resp = http.request request
      open(@fname, "wb") do |file|
        file.write(resp.body)
      end
    end
  end

  def extract
    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(@fname))
    tar_extract.rewind # The extract has to be rewinded after every iteration
    tar_extract.each do |entry|
      dest_file = File.join 'parts', entry.full_name.gsub(/^(crate)(\-\d+\.\d+\.\d+)(.*)/, '\1\3')
      puts dest_file
      if entry.directory?
        FileUtils.mkdir_p dest_file
      else
        dest_dir = File.dirname(dest_file)
        FileUtils.mkdir_p dest_dir unless File.directory?(dest_dir)
        File.open dest_file, "wb" do |f|
          f.print entry.read
        end
      end
    end
    tar_extract.close
  end
end

bootstrap = Bootstrap.new(*ARGV)
bootstrap.run()


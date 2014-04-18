require "crate_ruby/version"
require "crate_ruby/error"
require 'crate_ruby/result_set'
require 'crate_ruby/client'

include CrateRuby

module CrateRuby
  def self.logger
    @logger ||= begin
      require 'logger'
      log = Logger.new(File.join(File.dirname(__FILE__), "../log/crate.log"), 10, 1024000)
      log.level = Logger::INFO
      log
    end
  end

  def self.logger=(logger)
    @logger = logger
  end

end
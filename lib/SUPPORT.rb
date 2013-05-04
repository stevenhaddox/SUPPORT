require "SUPPORT/version"
require 'SUPPORT/config'
require 'SUPPORT/server'
require 'SUPPORT/user'
require 'SUPPORT/server_user'
require 'exceptions'

module SUPPORT

  def self.config
    SUPPORT::Config::CONFIG
  end

end

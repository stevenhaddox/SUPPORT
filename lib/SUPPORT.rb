require "SUPPORT/version"
require 'toml'
require 'SUPPORT/server'

module SUPPORT

  def self.config
    @config_file_path ||= File.exist?('config/support.toml') ? 'config/support.toml' : 'config/support.toml.example'
    @config ||= TOML.load_file(@config_file_path)
  end

end

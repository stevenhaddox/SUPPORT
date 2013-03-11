require 'toml'
module SUPPORT
  class Config
    config_file_path = File.exist?('config/support.toml') ? 'config/support.toml' : 'config/support.toml.example'
    CONFIG ||= TOML.load_file(config_file_path)
  end
end

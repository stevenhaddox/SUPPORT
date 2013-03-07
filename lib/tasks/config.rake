require 'SUPPORT'
require 'awesome_print'

namespace :support do
  desc "Output current configuration"
  task :config do
    ap SUPPORT.config
  end
end

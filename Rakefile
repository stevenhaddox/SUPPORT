require "bundler/gem_tasks"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new
task :default => :spec
task :test => :spec

# import all .rake files under lib/tasks
Dir.glob('lib/tasks/*.rake').each { |r| import r }

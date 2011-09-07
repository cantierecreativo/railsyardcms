# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

task :default => ['ry:clean_init', :cucumber]
task :travis do
  ['rake ry:clean_init', "rake cucumber"].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end

`echo 'test:
  adapter: sqlite3
  database: db/test.sqlite3
  timeout: 5000
  
development:
  adapter: sqlite3
  database: db/development.sqlite3
  timeout: 5000' > '#{File.expand_path('../config/database.yml', __FILE__)}'`

Railsyard2::Application.load_tasks

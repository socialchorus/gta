require 'gta'

namespace :deploy do
  stage_name_error = "stage name required, run rake with argument rake:deploy[staging]" 
  desc 'task that will be run before a deploy'
  task :before

  desc 'task that will be run after a deploy'
  task :after

  # the meat of a deploy, a git push from source to destination
  task :gta_push, :stage_name do |t, args| 
    raise stage_name_error unless stage_name = args[:stage_name]
    manager = GTA::Manager.new(ENV['GTA_CONFIG_PATH'])
    manager.push_to(stage_name)
  end

  # a forced version of the meat of the matter
  task :gta_force_push, :stage_name do |t, args|
    raise stage_name_error unless stage_name = args[:stage_name]
    manager = GTA::Manager.new(ENV['GTA_CONFIG_PATH'])
    manager.push_to(stage_name, :force)
  end

  task :wrap, :stage_name do |t, args|
    stage_name = args[:stage_name]
    Rake::Task["deploy:before"].invoke(stage_name)
    Rake::Task["deploy:gta_push"].invoke(stage_name)    
    Rake::Task["deploy:before"].invoke(stage_name)    
  end

  desc 'force push deploy, running before and after tasks'
  task :force, :stage_name do |t, args|
    stage_name = args[:stage_name]    
    Rake::Task["deploy:before"].invoke(stage_name)
    Rake::Task["deploy:gta_force_push"].invoke(stage_name)    
    Rake::Task["deploy:before"].invoke(stage_name)
  end
end

desc "push deploy, running before and after tasks"
task :deploy, :stage_name do |t, args|
  Rake::Task["deploy:wrap"].invoke(args[:stage_name])
end


require 'gta'

namespace :gta do
  desc 'add remote repositories for each of the configured environments'
  task :setup do
    manager = GTA::Manager.new(GTA::Manager.env_config)
    manager.setup
  end

  desc 'fetch latest stuff from each of the remotes'
  task :fetch do
    manager = GTA::Manager.new(GTA::Manager.env_config)
    manager.fetch
  end

  desc 'check out a tracking branch for the given stage'
  task :checkout, :stage_name do |t, args|
    raise GTA::Manager.stage_name_error unless stage_name = args[:stage_name]
    manager = GTA::Manager.new(GTA::Manager.env_config)
    manager.checkout(stage_name)
  end
end

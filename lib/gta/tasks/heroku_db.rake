namespace :heroku do
  namespace :db do
    desc 'download the database from the specified stage or from the last stage'
    task :fetch, :stage_name do |t, args|
      manager = GTA::Manager.new(GTA::Manager.env_config)
      stage = manager.stage(args[:stage_name]) || manager.final_stage
      GTA::HerokuDB.new(manager.app_name, stage.name).fetch
    end
  end
end

namespace :heroku do
  namespace :db do
    def gta_db
      @gta_db ||= GTA::DB.new(GTA::Manager.env_config, GTA::LocalDB.env_config, GTA::LocalDB.local_database_env)
    end

    desc 'download the database from the specified stage or from the last stage'
    task :fetch, :stage_name do |t, args|
      gta_db.fetch(args[:stage_name])
    end

    desc 'load local database with downloaded backup from stage'
    task :load, :stage_name do |t, args|
      gta_db.load(args[:stage_name])
    end

    desc 'restore remote database from another stage'
    task :restore, :stage_name do |t, args|
      gta_db.restore(args[:stage_name], ENV['source'])
    end
  end
end

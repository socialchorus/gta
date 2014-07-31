namespace :gta do
  namespace :heroku do
    namespace :db do
      def gta_db
        @gta_db ||= GTA::DB.new(GTA::Manager.env_config, GTA::LocalDB.local_database_env)
      end

      desc 'fetch and load the remote database'
      task :pull, :stage_name do |t, args|
        Bundler.with_clean_env{ Rake::Task['gta:heroku:db:fetch'].invoke(args[:stage_name]) }
        Bundler.with_clean_env{ Rake::Task['gta:heroku:db:load'].invoke(args[:stage_name]) }
      end

      desc 'download the database from the specified stage or from the last stage'
      task :fetch, :stage_name do |t, args|
        Bundler.with_clean_env{ gta_db.fetch(args[:stage_name]) }
      end

      desc 'load local database with downloaded backup from stage'
      task :load, :stage_name do |t, args|
        gta_db.load(args[:stage_name])
      end

      desc 'restore remote database from another stage'
      task :restore, :stage_name do |t, args|
        Bundler.with_clean_env{ gta_db.restore(args[:stage_name], ENV['source']) }
      end
    end
  end
end

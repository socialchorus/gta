namespace :gta do
  namespace :deploy do
    desc 'task that will be run before a deploy'
    task :before, :stage_name

    desc 'task that will be run after a deploy'
    task :after, :stage_name

    def deployer(args)
      stage_name = args[:stage_name]
      GTA::Deploy.new(stage_name, GTA::Manager.env_config)
    end

    # the meat of a deploy, a git push from source to destination
    task :gta_push, :stage_name do |t, args|
      deployer(args).deploy
    end

    # a forced version of the meat of the matter
    task :gta_force_push, :stage_name do |t, args|
      deployer(args).deploy(:force)
    end

    task :deploy, :stage_name do |t, args|
      stage_name = args[:stage_name]
      Rake::Task["gta:deploy:before"].invoke(stage_name)
      Rake::Task["gta:deploy:gta_push"].invoke(stage_name)
      Rake::Task["gta:deploy:after"].invoke(stage_name)
    end

    desc 'force push deploy, running before and after tasks'
    task :force, :stage_name do |t, args|
      stage_name = args[:stage_name]
      Rake::Task["gta:deploy:before"].invoke(stage_name)
      Rake::Task["gta:deploy:gta_force_push"].invoke(stage_name)
      Rake::Task["gta:deploy:after"].invoke(stage_name)
    end
  end

  desc "push deploy, running before and after tasks"
  task :deploy, :stage_name do |t, args|
    Rake::Task["gta:deploy:deploy"].invoke(args[:stage_name])
  end
end

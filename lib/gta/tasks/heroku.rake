namespace :gta do
  namespace :heroku do
    def stage_name!(args)
      return @stage_name if @stage_name
      @stage_name = args[:stage_name]
      raise "stage name required" unless @stage_name
      @stage_name
    end

    def app_argument(args)
      manager = GTA::Manager.new(GTA::Manager.env_config)
      manager.account.blank? ? "--app #{manager.app_name}-#{stage_name!(args)}" : "--app #{manager.app_name}-#{stage_name!(args)} --account #{manager.account}"
    end

    desc "turn maintenance on for this stage"
    task :maintenance_on, :stage_name do |t, args|
      GTA::Commander.new("heroku maintenance:on #{app_argument(args)}").perform
    end

    desc "turn maintenance on for this stage"
    task :maintenance_off, :stage_name do |t, args|
      GTA::Commander.new("heroku maintenance:off  #{app_argument(args)}").perform
    end

    desc "run a heroku rake task in specified stage"
    task :rake, :stage_name, :command do |t, args|
      command = args[:command]
      GTA::Commander.new("heroku run rake #{command} #{app_argument(args)}").perform
    end
  end
end

module GTA
  class DB
    attr_reader :gta_config_path, :database_config_path, :local_env

    def initialize(gta_config_path=nil, database_config_path=nil, local_env=nil)
      @gta_config_path = gta_config_path
      @database_config_path = database_config_path
      @local_env = local_env || 'development'
    end

    def manager
      @manager ||= Manager.new(gta_config_path)
    end

    def local_db
      @local_db ||= LocalDB.new(local_env, database_config_path)
    end

    def fetch(stage_name=nil)
      stage = stage_or_final(stage_name)
      db(stage.name).fetch
    end

    def load(stage_name=nil)
      stage = stage_or_final(stage_name)
      heroku_db = db(stage.name)
      local_db.load(heroku_db.file_name)
    end

    def pull(stage_name=nil)
      stage = stage_or_final(stage_name)
      fetch(stage.name)
      self.load(stage.name)
    end

    def restore(destination_name, source_name=nil)
      source = stage_or_final(source_name)
      destination = manager.stage!(destination_name)

      raise "cannot restore #{destination.name}" unless destination.restorable?

      source_db = db(source.name)
      source_db.backup

      destination_db = db(destination.name)
      destination_db.restore_from(source_db.url)
    end

    def stage_or_final(stage_name)
      manager.stage(stage_name) || manager.final_stage
    end

    def db(stage_name)
      HerokuDB.new(manager.app_name, stage_name)
    end
  end
end

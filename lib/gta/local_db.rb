module GTA
  class LocalDB
    include Sh

    attr_reader :database_config_path, :env

    def initialize(env, database_config_path=nil)
      @env = env
      @database_config_path = database_config_path || self.class.default_database_config_path
    end

    def load(backup_path)
      sh "pg_restore --verbose --clean --no-acl --no-owner -h localhost#{username}#{database} #{backup_path}"
    end

    def config
      @config ||= YAML.load(File.read(database_config_path))[env]
    end

    def username
      config['username'] ? " -U #{config['username']}" : ''
    end

    def database
      config['database'] ? " -d #{config['database']}" : ''
    end

    def self.default_database_config_path
      "#{Dir.pwd}/config/database.yml"
    end

    def self.env_config
      ENV['GTA_DATABASE_CONFIG_PATH']
    end

    def self.local_database_env
      ENV['RAILS_ENV'] || ENV['GTA_LOCAL_ENV']
    end
  end
end

module GTA
  class LocalDB
    include Sh

    attr_reader :database_config_path, :env

    def initialize(env, database_config_path=nil)
      @env = env
      @database_config_path = database_config_path || self.class.default_database_config_path
    end

    def load(backup_path)
      sh("pg_restore --verbose --clean --no-acl --no-owner -h localhost#{username}#{database} #{backup_path}")
    end

    def config
      @config ||= parsed_config[env]
    end

    def file_contents
      File.read(database_config_path)
    end

    def parsed_config
      database_config_path.match(/yml$/) ? YAML.load(file_contents) : JSON.parse(file_contents)
    end

    def _username
      config['username'] || config['user']
    end

    def username
      _username ? " -U #{_username}" : ''
    end

    def database
      config['database'] ? " -d #{config['database']}" : ''
    end

    def self.default_database_config_path
      "#{Dir.pwd}/config/database.yml"
    end

    def self.local_database_env
      ENV['RAILS_ENV'] || ENV['GTA_LOCAL_ENV']
    end
  end
end

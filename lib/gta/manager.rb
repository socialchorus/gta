module GTA
  class Manager
    attr_reader :config_path

    def initialize(config_path = nil)
      @config_path = config_path || "#{Dir.pwd}/config/gta.yml"
    end

    def push_to(name, forced = nil)
      s = stage!(name)
      fetch!
      if forced == :force
        s.force_push
      else
        s.push
      end
    end

    def account
      @account || config && @account
    end

    def app_name
      @app_name || config && @app_name
    end

    def database_config_path
      @database_config_path || config && @database_config_path
    end

    def checkout(name)
      stage!(name).fetch
      stage!(name).checkout
    end

    alias :co :checkout

    def fetch
      stages.each(&:fetch)
    end

    def fetch!
      stages.each(&:fetch!)
    end

    def setup
      stages.each(&:add_remote)
    end

    def config
      return @config if @config
      parsed = YAML.load(File.read(config_path))
      @account = parsed['account']
      @app_name = parsed['name']
      @database_config_path = find_database_config(parsed['database_config'])
      @config = parsed['stages']
    end

    def find_database_config(path)
      if path
        File.dirname(config_path) + "/#{path}"
      else
        LocalDB.default_database_config_path
      end
    end

    def stages
      @stages ||= config.map{ |name, opts| Stage.new(name, self, opts) }
    end

    def stage(name)
      stages.detect{|s| s.name == name.to_s}
    end

    def final_stage
      stages.detect{|s| s.final? } || stages.last
    end

    def hotfixer(stage_name=nil)
      hotfixers = stages.select{|s| s.hotfixable?}
      default = stage_name == nil ? hotfixers.first : nil
      hotfixers.detect{|s| s.name == stage_name} || default
    end

    def stage!(name)
      stage(name) || (raise ArgumentError.new("Stage #{name} not found"))
    end

    def self.env_config
      ENV['GTA_CONFIG_PATH']
    end

    def self.stage_name_error
      "Stage name required. Run rake with argument - `rake:deploy[staging]`"
    end
  end
end

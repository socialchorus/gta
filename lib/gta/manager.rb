module GTA
  class Manager
    attr_reader :config_path

    def initialize(config_path = nil)
      @config_path = config_path || "#{Dir.pwd}/config/gta.yml"
    end

    def push_to(name, forced = nil)
      s = stage!(name)
      fetch
      if forced == :force
        s.force_push
      else
        s.push
      end
    end

    def checkout(name)
      stage!(name).checkout
    end

    alias :co :checkout

    def fetch
      stages.each(&:fetch)
    end

    def setup
      stages.each(&:add_remote)
    end

    def config
      @config ||= YAML.load(File.read(config_path))
    end

    def stages
      @stages ||= config.map{ |name, opts| Stage.new(name, self, opts) }
    end

    def stage(name)
      stages.detect{|s| s.name == name.to_s}
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

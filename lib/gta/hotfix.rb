module GTA
  class Hotfix
    include Sh

    attr_reader :gta_config_path

    def initialize(gta_config_path = nil)
      @gta_config_path = gta_config_path
    end

    def checkout(stage_name=nil)
      stage = stage_for(stage_name)
      sh!("git fetch #{stage.name}")
      not_hotfixable!(stage_name) unless stage
      stage.checkout
    end

    def manager
      @manager ||= Manager.new(gta_config_path)
    end

    def deploy
      stage_name = branch_name
      stage = stage_for(stage_name)
      not_hotfixable!(stage_name) if !stage || !stage_name
      sh!("git push #{stage_name} #{stage_name}:master")
    end

    def not_hotfixable!(stage_name)
      raise "stage #{stage_name} not hotfixable"
    end

    def stage_for(stage_name)
      manager.hotfixer(stage_name)
    end

    def branch_name
      branches = sh!("git branch").strip
      matches = branches.match(/\*\s+(.*)/)
      matches[1].strip if matches
    end
  end
end

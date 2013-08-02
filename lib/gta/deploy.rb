module GTA
  class Deploy
    attr_reader :gta_config_path, :stage_name

    def initialize(stage_name, gta_config_path=nil)
      @stage_name = stage_name
      @gta_config_path = gta_config_path
    end

    def manager
      @manager ||= Manager.new(gta_config_path)
    end

    def destination
      @destination ||= manager.stage!(stage_name)
    end

    def source
      @source ||= destination.source
    end

    def deploy(forced=nil)
      destination.fetch!
      source.fetch!

      source.checkout! # so the tracking branch exists

      forced == :force ? destination.force_push : destination.push
    end
  end
end

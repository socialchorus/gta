module GTA
  class Diff
    include Sh

    attr_reader :source_name, :destination_name, :gta_config_path

    DEFAULT_FORMAT = 'short'

    def initialize(source_name, destination_name, gta_config_path=nil)
      @source_name = source_name
      @destination_name = destination_name
      @gta_config_path = gta_config_path
    end

    def manager
      @manager ||= Manager.new(gta_config_path)
    end

    def source
      @source ||= manager.stage!(source_name)
    end

    def destination
      @destination ||= manager.stage!(destination_name)
    end

    def report(format=DEFAULT_FORMAT)
      source.fetch!
      destination.fetch!
      sh("git log #{source.name}/master..#{destination.name}/master --format=#{format}")
    end

    def shas
      report('%h')
    end

    def cherry_pick
      commits = shas.split("\n")
      sh("git checkout #{destination.name}")
      commits.each do |sha|
        sh("git cherry-pick #{sha}")
      end
    end
  end
end

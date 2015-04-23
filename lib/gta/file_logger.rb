require 'fileutils'

module GTA
  class FileLogger
    attr_reader :log_dir

    def initialize(log_dir=nil)
      @log_dir = log_dir ||= "#{Dir.pwd}/log"
      ensure_log_dir_and_file
    end

    def ensure_log_dir_and_file
      FileUtils.mkdir_p(log_dir)
      FileUtils.touch(log_file) unless File.exist?(log_file)
    end

    def log_file
      "#{log_dir}/gta.log"
    end

    def write(stuff)
      File.open(log_file, 'a') do |f|
        f.write(stuff)
      end
    end
  end
end

module GTA
  class Commander
    attr_reader :command, :output, :exit_status

    LINE_LENGTH = 80

    def initialize(command=nil)
      @output = []
      @command = command
    end

    def perform
      _perform(false)
    end

    def perform!
      _perform(true)
    end

    def write_output(line)
      message = normalize_output(" #{line}")
      puts "#{ANSI.white_on_black}#{message}"
      output << line
    end

    def write_failure(message = command)
      message = normalize_output(" Command failed: #{message}")
      puts "#{ANSI.red_on_black}#{message}#{ANSI.ansi}"
      write_to_log(message)
      write_to_log("-"*LINE_LENGTH)
    end

    # --------------

    def _perform(should_raise)
      run_command(should_raise)
      puts_reset

      write_to_log(output.join)
      handle_failure(should_raise) unless exit_status && exit_status.success?

      output.join
    end

    def run_command(should_raise)
      write_command
      Open3.popen3(command) do |stdin, stdout, stderr, process_status|
        stderr.sync = true
        stdout.sync = true

        while (line = stderr.gets)
          write_output line
        end

        while (line = stdout.gets)
          write_output line
        end

        @exit_status = process_status.value
      end
    rescue Errno::ENOENT => e
      handle_failure(should_raise, e)
    end

    def handle_failure(should_raise, e=nil)
      write_failure
      if e
        output << e.message
        write_failure(e.message)
        write_failure(e.backtrace)
      end
      raise CommandFailure, "FAILED! #{command}" if should_raise
    end

    def normalize_output(output)
      normalized = output.gsub("\n",'') 
      normalized += " "*(LINE_LENGTH-normalized.size-1) if normalized.size < LINE_LENGTH
      normalized += ' '
      normalized
    end

    def write_command
      message = normalize_output(" GTA: #{command}")
      puts "#{ANSI.black_on_white}#{message}#{ANSI.ansi}"
      write_to_log(command)
      write_to_log("-"*LINE_LENGTH)
    end

    def puts_reset
      puts "#{ANSI.ansi}"
    end

    def logger
      @logger ||= FileLogger.new
    end

    def write_to_log(response)
      logger.write(response)
    end

    class CommandFailure < StandardError
    end
  end
end

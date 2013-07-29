module GTA
  module Sh
    def sh(command)
      puts "#{ANSI.black_on_white} GTA: #{command} #{ANSI.ansi}"
      system(command)
    end
  end
end

module GTA
  module Sh
    def sh(command)
      commander(command).perform
    end

    def sh!(command)
      commander(command).perform
    end

    def commander(command=nil)
      Commander.new(command)
    end
  end
end

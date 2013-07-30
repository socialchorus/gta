module GTA
  class Railtie < Rails::Railtie
    rake_tasks do
      require File.dirname(__FILE__) + "/tasks.rb"
    end
  end
end
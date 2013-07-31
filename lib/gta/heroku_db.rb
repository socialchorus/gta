module GTA
  class HerokuDB
    include GTA::Sh

    attr_reader :env, :app, :database_yml_path

    def initialize(app, env)
      @env = env
      @app = app
    end

    def url
      sh!("heroku pgbackups:url --app #{app_signature}").strip
    end

    def backup
      sh("heroku pgbackups:capture --expire --app #{app_signature}")
    end

    def restore_from(url)
      sh!("heroku pgbackups:restore DATABASE_URL \"#{url}\" --app #{app_signature} --confirm #{app_signature}")
    end

    def fetch
      sh!("curl -o #{file_name} \"#{url}\"")
    end

    def file_name
      "~/Downloads/#{app_signature}.sql"
    end

    def app_signature
      "#{app}-#{env}"
    end
  end
end


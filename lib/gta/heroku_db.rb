module GTA
  class HerokuDB
    include GTA::Sh

    attr_reader :env, :app, :database_yml_path

    def initialize(app, env)
      @env = env
      @app = app
    end

    def url
      sh!("heroku pg:backups public-url --app #{app_signature}").strip
    end

    def backup
      sh("heroku pg:backups capture --expire --app #{app_signature}")
    end

    def restore_from(url)
      sh!("heroku pg:backups restore \"#{url}\" DATABASE_URL --app #{app_signature} --confirm #{app_signature}")
    end

    def fetch
      sh!("curl -o #{file_name} \"#{url}\"")
    end

    def file_name
      "/tmp/#{app_signature}.sql"
    end

    def app_signature
      "#{app}-#{env}"
    end
  end
end


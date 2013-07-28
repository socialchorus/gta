module Remote
  class DB
    attr_reader :env, :app

    def initialize(env, app)
      raise "Environment not allowed" unless ['qa', 'staging'].include?(env)
      @env = env
      @app = app
    end

    def reset
      puts "==> RESETTING the #{app}-#{env} db..."
      `heroku pg:reset DATABASE --app #{app}-#{env} --confirm #{app}-#{env}`
    end

    def restore
      puts "==> RESTORING #{app}-#{env} from latest backup..."
      `heroku pgbackups:restore DATABASE_URL "#{DB::Config.db_url(app)}" --app #{app}-#{env} --confirm #{app}-#{env}`
    end
  end
end


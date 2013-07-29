require 'spec_helper'

describe GTA::LocalDB do
  let(:env) { 'development' }
  let(:database_config_path) { File.dirname(__FILE__) + "/fixtures/config/database.yml" }
  let(:local_db) { GTA::LocalDB.new(env, database_config_path) }

  describe '#load' do
    it "does a postgres load of the right database based on the config" do
      local_db.should_receive(:sh).with(
        "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U socialchorus -d activator_dev ~/Downloads/activator-staging.sql"
      )
      local_db.load("~/Downloads/activator-staging.sql")
    end
  end
end

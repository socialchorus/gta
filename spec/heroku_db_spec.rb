require 'spec_helper'

describe GTA::HerokuDB do
  let(:database_yml_path) { File.dirname(__FILE__) + "/fixtures/config/database.yml" }
  let(:heroku_db) { GTA::HerokuDB.new('activator', 'staging') }

  describe '#url' do
    it "gets the temporary database url from heroku" do
      heroku_db.should_receive(:sh)
        .with("heroku pgbackups:url --app activator-staging")
        .and_return('backup url')
      heroku_db.url.should == 'backup url'
    end
  end

  describe '#backup' do
    it "sends a heroku command to backup the databse, with the expire flag" do
      heroku_db.should_receive(:sh)
        .with("heroku pgbackups:capture --expire --app activator-staging")
      heroku_db.backup
    end
  end

  describe '#restore_from(url)' do
    it "sends a heroku command to restore the database from the given url" do
      heroku_db.should_receive(:sh)
        .with('heroku pgbackups:restore DATABASE_URL "http://my-database-url.com" --app activator-staging --confirm activator-staging')
      heroku_db.restore_from("http://my-database-url.com")
    end
  end

  describe '#fetch' do
    it "downloads the latest database backup to an appropriately named file in downloads" do
      heroku_db.should_receive(:url).and_return('http://heroku-backup-url.com')
      heroku_db.should_receive(:sh)
        .with('curl -o ~/Downloads/activator-staging.sql "http://heroku-backup-url.com"')
      heroku_db.fetch
    end
  end
end

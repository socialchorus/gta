require 'spec_helper'

describe GTA::DB do
  let(:config_path) { File.dirname(__FILE__) + "/fixtures/config" }
  let(:gta_config_path) { "#{config_path}/gta.yml" }
  let(:database_config_path) { "#{config_path}/database.yml" }
  let(:db) { GTA::DB.new(gta_config_path, database_config_path) }
  let(:heroku_db) { double(fetch: true) }

  before do
    GTA::HerokuDB.stub(:new).and_return(heroku_db)
  end

  it "has a manager" do
    db.manager.should be_a(GTA::Manager)
  end

  describe "#fetch" do
    context "when a stage is provided" do
      it "will construct a heroku db object with the right stage information" do
        GTA::HerokuDB.should_receive(:new)
          .with('activator', 'staging')
          .and_return(heroku_db)
        db.fetch('staging')
      end

      it "will call #fetch on the heroku db object" do
        heroku_db.should_receive(:fetch)
        db.fetch('staging')
      end
    end

    context "when a stage is not provided" do
      it "will use the default stage" do
        GTA::HerokuDB.should_receive(:new)
          .with('activator', 'qa')
          .and_return(heroku_db)
        db.fetch
      end
    end
  end

  describe '#load' do
    let(:local_db) { double('local_db') }

    before do
      db.stub(:local_db).and_return(local_db)
    end

    context "when no source is given" do
      it "loads the last stage's download into the local database" do
        GTA::HerokuDB.should_receive(:new)
          .with('activator', 'qa')
          .and_return(heroku_db)
        heroku_db.stub(:file_name).and_return("~/Downloads/activator-qa.sql")
        local_db.should_receive(:load).with("~/Downloads/activator-qa.sql")
        db.load
      end
    end

    context "when a source is passed" do
      it "loads the source download into the local database" do
        GTA::HerokuDB.should_receive(:new)
          .with('activator', 'production')
          .and_return(heroku_db)
        heroku_db.stub(:file_name).and_return("~/Downloads/activator-production.sql")
        local_db.should_receive(:load).with("~/Downloads/activator-production.sql")
        db.load('production')
      end
    end
  end

  describe '#pull' do
    it "calls #fetch with the source (default or other)" do
      db.should_receive(:fetch).with('qa')
      db.should_receive(:load).with('qa')
      db.pull
    end

    it "calls #load with the source (default or other)" do
      db.should_receive(:fetch).with('production')
      db.should_receive(:load).with('production')
      db.pull('production')
    end
  end

  describe '#restore' do
    let(:manager) { db.manager }
    let(:source_heroku_db) { double('source db', backup: true, url: 'source-url') }
    let(:destination_heroku_db) { double('destination db', restore_from: true) }

    context 'when the destination stage is not restorable' do
      it "raises an error" do
        expect {
          db.restore('production')
        }.to raise_error
      end
    end

    context "when the stage is restorable, and no source stage information is given" do
      before do
        GTA::HerokuDB.stub(:new) do |app_name, stage_name|
          if stage_name == 'qa'
            source_heroku_db
          elsif stage_name == 'staging'
            destination_heroku_db
          end
        end
      end

      it "makes a backup of the final stage" do
        source_heroku_db.should_receive(:backup)
        db.restore('staging')
      end

      it "gets the url for the final stage's database" do
        source_heroku_db.should_receive(:url).and_return('source-url')
        db.restore('staging')
      end

      it "calls restore on the destination stage with the database url" do
        destination_heroku_db.should_receive(:restore_from).with('source-url')
        db.restore('staging')
      end
    end

    context "when a second 'source' stage is specified" do
      before do
        GTA::HerokuDB.stub(:new) do |app_name, stage_name|
          if stage_name == 'production'
            source_heroku_db
          elsif stage_name == 'qa'
            destination_heroku_db
          end
        end
      end

      it "makes a backup of the source stage" do
        source_heroku_db.should_receive(:backup)
        db.restore('qa', 'production')
      end

      it "gets the url for the source's database" do
        source_heroku_db.should_receive(:url).and_return('source-url')
        db.restore('qa', 'production')
      end

      it "calls restore on the destination stage with the database url" do
        destination_heroku_db.should_receive(:restore_from).with('source-url')
        db.restore('qa', 'production')
      end
    end
  end
end

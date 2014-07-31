require 'spec_helper'

describe GTA::Manager do
  let(:config_path) { File.dirname(__FILE__) + "/fixtures/config/gta.yml" }
  let(:manager) { GTA::Manager.new(config_path) }

  it "builds stages for each entry in the yml" do
    manager.stages.size.should == 5
    manager.stages.map(&:class).uniq.should == [GTA::Stage]
  end

  it "has an app name" do
    manager.app_name.should == 'activator'
  end

  it "has a reference to the database config file" do
    File.expand_path(manager.database_config_path).should ==
      File.expand_path(File.dirname(__FILE__) + "/fixtures/config/database.yml")
  end

  describe '#fetch' do
    it "loops through each stage and calls fetch" do
      manager.stages.each do |stage|
        stage.should_receive(:fetch)
      end
      manager.fetch
    end
  end

  describe '#stage' do
    it "finds the right stage by name" do
      manager.stage('qa').should be_a(GTA::Stage)
      manager.stage(:qa).name.should == 'qa'
    end
  end

  describe '#stage!' do
    it 'raises an error if it cannot find the right stage' do
      expect {
        manager.stage!(:foo)
      }.to raise_error
    end

    it 'finds and return the right stage otherwise' do
      manager.stage!(:ci).should be_a(GTA::Stage)
    end
  end

  describe '#final_stage' do
    context "when there are more than one final stages" do
      before do
        manager.stages.first.stub(:final?).and_return(true)
      end

      it "returns the first stage that responds to #final? with true" do
        manager.final_stage.should == manager.stages.first
      end
    end

    context "when there is only one final stage" do
      it "returns the only one defined" do
        manager.final_stage.name.should == 'qa'
      end
    end

    context "when there are no final stages" do
      before do
        manager.stages.each{|s| s.stub(:final?).and_return(false) }
      end

      it "chooses the last stage in the configuration" do
        manager.final_stage.name.should == 'production'
      end
    end
  end

  describe '#hotfixer' do
    context 'when not passed a stage name' do
      it "returns the first stage that is hotfixable" do
        manager.hotfixer.name.should == 'staging'
      end
    end

    context "when passed a stage name" do
      context "when the stage name matches a hotfixable stage" do
        it "returns the stage" do
          manager.hotfixer('qa').name.should == 'qa'
        end
      end

      context "when the stage name matches as non hotfixbale stage" do
        it "returns nil" do
          manager.hotfixer('production').should == nil
        end
      end
    end
  end

  describe '#push_to' do
    before do
      manager.stub(:fetch!)
      manager.stage(:qa).stub(:push)
    end

    it "fetches" do
      manager.should_receive(:fetch!)
      manager.push_to(:qa)
    end

    it "tells the right stage to push itself" do
      manager.stage(:qa).should_receive(:push)
      manager.push_to(:qa)
    end

    it "will force with the right arguments" do
      manager.stage(:qa).should_receive(:force_push)
      manager.push_to(:qa, :force)
    end
  end

  describe '#setup' do
    it 'adds a remote for each stage' do
      manager.stages.each do |stage|
        stage.should_receive(:add_remote)
      end
      manager.setup
    end
  end

  context 'when heroku account is specified' do
    let(:config_path_with_account) { File.dirname(__FILE__) + "/fixtures/config/gta_with_account.yml" }
    let(:manager_with_account) { GTA::Manager.new(config_path_with_account) }

    it 'has an account name' do
      expect(manager_with_account.account).to eq 'socialchorus'
    end
  end
end

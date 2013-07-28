require 'spec_helper'

describe GTA::Manager do
  let(:config_path) { File.dirname(__FILE__) + "/fixtures/config/gta.yml" }
  let(:manager) { GTA::Manager.new(config_path) }

  it "builds stages for each entry in the yml" do
    manager.stages.size.should == 5
    manager.stages.map(&:class).uniq.should == [GTA::Stage]
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

  describe '#push_to' do
    before do
      manager.stub(:fetch)
      manager.stage(:qa).stub(:push)
    end

    it "fetches" do
      manager.should_receive(:fetch)
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
end

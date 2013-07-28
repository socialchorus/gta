require 'spec_helper'

describe GTA::Manager do
  let(:config_path) { File.dirname(__FILE__) + "/fixtures/config/gta.yml" }
  let(:manager) { GTA::Manager.new(config_path) }

  it "builds stages for each entry in the yml" do
    manager.stages.size.should == 4
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
    it "tells the right stage to push itself" do
      manager.stage(:qa).should_receive(:push)
      manager.push_to(:qa)
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

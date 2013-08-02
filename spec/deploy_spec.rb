require 'spec_helper'

describe GTA::Deploy do
  let(:config_path) { File.dirname(__FILE__) + "/fixtures/config/gta.yml" }
  let(:deployer) { GTA::Deploy.new('qa', config_path) }
  let(:destination) { deployer.destination }
  let(:source) { deployer.source }

  it "has the right source and destination" do
    destination.name.should == 'qa'
    source.name.should == 'staging'
  end

  describe '#deploy' do
    before do
      destination.stub(:fetch!)
      destination.stub(:push)
      destination.stub(:force_push)

      source.stub(:checkout!)
      source.stub(:fetch!)

      deployer.stub(:sh)
    end

    it "fetches the destination" do
      destination.should_receive(:fetch!)
      deployer.deploy
    end

    it "fetches the source" do
      source.should_receive(:fetch!)
      deployer.deploy
    end

    it "checks out the source" do
      source.should_receive(:checkout!)
      deployer.deploy
    end

    context "non-forced push" do
      it "pushes the destination" do
        destination.should_receive(:push)
        deployer.deploy
      end
    end

    context "forced push" do
      it "forces a push" do
        destination.should_receive(:force_push)
        deployer.deploy(:force)
      end
    end
  end
end

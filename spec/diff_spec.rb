require 'spec_helper'

describe GTA::Diff do
  let(:gta_config_path) { File.dirname(__FILE__) + "/fixtures/config/gta.yml" }
  let(:diff) { GTA::Diff.new('staging', 'production', gta_config_path) }

  before do
    diff.stub(:sh)
    diff.source.stub(:fetch!)
    diff.destination.stub(:fetch!)
  end

  describe 'stages' do
    it "gets a source from the manager" do
      diff.source.name.should == 'staging'
    end

    it "gets a destination from the manager" do
      diff.destination.name.should == 'production'
    end
  end

  describe '#report' do
    it "should fetch the stages" do
      diff.source.should_receive(:fetch!)
      diff.destination.should_receive(:fetch!)

      diff.report
    end

    it "sends the right command" do
      diff.should_receive(:sh)
        .with("git log staging/master..production/master --format=short")
      diff.report
    end
  end

  describe '#cherry_pick' do
    let(:cherry_pick_commands) { [] }
    let(:checkout_commands) { [] }

    before do
      diff.stub(:sh) do |command|
        if command.match(/git log/)
          "12345\n23456\n34567\n"
        elsif command.match(/git checkout/)
          checkout_commands << command
        else
          cherry_pick_commands << command
        end
      end
    end

    it "checks out the destination" do
      diff.cherry_pick
      checkout_commands.first.should == "git checkout production"
    end

    it "sends a cherry pick command for each sha" do
      diff.cherry_pick
      cherry_pick_commands.should == [
        "git cherry-pick 12345",
        "git cherry-pick 23456",
        "git cherry-pick 34567",
      ]
    end
  end
end

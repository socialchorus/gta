require 'spec_helper'

describe GTA::Hotfix do
  let(:gta_config_path) { File.dirname(__FILE__) + "/fixtures/config/gta.yml" }
  let(:hotfix) { GTA::Hotfix.new(gta_config_path) }
  let(:manager) { hotfix.manager }
  let(:stage) { double(checkout: true, name: 'staging') }

  describe '#checkout' do
    context "no stage provided" do

      it "gets the first hotfixable stage" do
        hotfix.should_receive(:sh!).with("git fetch #{stage.name}")
        manager.should_receive(:hotfixer)
          .and_return(stage)
        hotfix.checkout
      end

      it "finds and checks out the first hotfixable stage" do
        hotfix.stub(:sh!)
        manager.should_receive(:hotfixer).with(nil).and_return(stage)
        stage.should_receive(:checkout)
        hotfix.checkout
      end
    end

    context "stage is not hotfixable" do
      it "raises an error" do
        expect {
          hotfix.checkout('production')
        }.to raise_error
      end
    end

    context "stage is hotfixable" do
      it "checks out that stage" do
        hotfix.should_receive(:sh!).with("git fetch staging")
        manager.should_receive(:hotfixer)
          .with('staging')
          .and_return(stage)
        stage.should_receive(:checkout)
        hotfix.checkout('staging')
      end
    end
  end

  describe '#deploy' do
    context "when on a branch that maps to a stage" do
      before do
        hotfix.stub(:sh!) do |command|
          if command == "git branch"
            branch_output
          else
            "deploying"
          end
        end
      end

      context "if it is hotfixable" do
        let(:branch_output) {
          "  bunny\n  ftc_language\n* qa\n  production"
        }

        it "should call #sh with the right deploy command" do
          hotfix.should_receive(:sh!)
            .with("git push qa qa:master")
            .and_return("deploying")
          hotfix.deploy.should == "deploying"
        end
      end

      context "if it is not hotfixable" do
        let(:branch_output) {
          "  bunny\n  ftc_language\n* master\n  production"
        }

        it "raises an error" do
          expect {
            hotfix.deploy
          }.to raise_error
        end
      end
    end
  end
end

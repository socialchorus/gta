require 'spec_helper'

describe GTA::Stage do
  let(:tag) { nil }
  let(:branch) { nil }
  let(:repository) { "git@github.com:socialchorus/activator.git" }
  let(:opts) {
    {
      "source" => "ci",
      "repository" => repository,
      "tag" => tag,
      "branch" => branch
    }
  }
  let(:stage)  { GTA::Stage.new('staging', manager, opts) }
  let(:source) { GTA::Stage.new('ci', manager, opts.merge('source' => 'origin')) }
  let(:manager) { double('manager') }

  before do
    manager.stub(:stage!).and_return(source)
    stage.stub(:sh)
  end

  describe 'initalization' do
    it "has a name" do
      stage.name.should == 'staging'
    end

    it "stores the repository" do
      stage.repository.should == 'git@github.com:socialchorus/activator.git'
    end

    it "stores the intended source stage" do
      stage.source_name.should == 'ci'
    end

    it "creates a default branch" do
      stage.branch.should == 'master'
    end
  end

  describe '#checkout' do
    it "send the command to checkout a tracking branch from the remote" do
      stage.should_receive(:sh).with("git checkout -b staging -t staging/master")
      stage.checkout
    end
  end

  describe '#fetch' do
    it "calls the right git command" do
      stage.should_receive(:sh).with("git fetch staging")
      stage.fetch
    end
  end

  describe '#source' do
    it "gets the source based on the source name" do
      stage.source.should == source
    end
  end

  describe '#add_remote' do
    context 'when the repository is nil' do
      let(:repository) { nil }

      it "should raise an error" do
        expect {
          stage.add_remote
        }.to raise_error
      end
    end

    context 'when all is good' do
      it "should call #sh with the right git command if there is a repository" do
        stage.should_receive(:sh).with("git remote add staging #{repository}")
        stage.add_remote
      end
    end
  end

  describe '#push' do
    # private ... delete tests after #push fully tested
    describe '#push_command' do
      context "without a tag and branch is default" do
        it "should be a string that allows the interpolation of the source" do
          stage.push_command('source').should == 'git push staging source:master'
        end
      end

      context "with an alternate branch" do
        let(:branch) { 'alt' }

        it "should push to the other branch instead" do
          stage.push_command('source').should == 'git push staging source:alt'
        end
      end
    end

    context "when using internally defined source object" do
      it "sends the right git shell command" do
        stage.should_receive(:sh).with("git push staging ci:master")
        stage.push
      end
    end

    context "when passed an alternative source object" do
      let(:origin) { GTA::Stage.new('origin', manager, opts.merge('branch' => 'sendit')) }

      it "sends the right git shell command" do
        stage.should_receive(:sh).with("git push staging origin:master")
        stage.push(origin)
      end
    end

    context "when passed a string identifying the source (and an alt branch)" do
      let(:branch) { 'alt_branch' }

      it "sends the right git shell command" do
        stage.should_receive(:sh).with("git push staging foo:alt_branch")
        stage.push('foo')
      end
    end

    context "when the source has a tag" do
      let(:tag) { 'my-tag' }

      it "uses the tag as the source reference" do
        stage.should_receive(:sh).with("git push staging my-tag:master")
        stage.push
      end
    end

    context "force push" do
      it "adds the -f flag to the git command" do
        stage.should_receive(:sh).with("git push -f staging ci:master")
        stage.force_push
      end
    end
  end
end

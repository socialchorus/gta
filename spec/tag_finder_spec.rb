require 'spec_helper'

describe GTA::TagFinder do
  let(:finder) { GTA::TagFinder.new(tag)}

  describe '#newest' do
    context 'it receives a tag' do
      let(:tag) { 'ci/*' }
      before do
        finder.stub(:`).and_return(git_response)
      end

      context 'we get a list from git' do
        let(:git_response) {
          "ci/12310\nci/12313\nci/29374"
        }

        it 'should return the most recent one' do
          finder.newest.should == "ci/29374"
        end
      end

      context 'we get a single line from git' do
        let(:git_response) {
          "ci/29374"
        }

        it 'should return it' do
          finder.newest.should == "ci/29374"
        end
      end

      context 'we get an empty string from git' do
        let(:git_response) { "" }

        it 'should be nil' do
          finder.newest.should == nil
        end
      end
    end

    context 'it receives nothing' do
      let(:tag) { nil }

      it "returns nothing" do
        finder.newest.should == nil
      end
    end
  end
end
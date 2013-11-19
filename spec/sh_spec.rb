require 'spec_helper'


describe GTA::Sh do
  include GTA::Sh

  let(:log_path) { File.dirname(__FILE__) + "/../log/gta.log" }
  let(:log) { File.read(log_path) }
  
  before do
    File.delete(log_path) if File.exist?(log_path)
  end

  context 'when sh is not successful' do
    it "does not raise an exception" do
      capture_stdout do 
        expect {
          sh("foo")
        }.not_to raise_error
      end
    end
  end

  context 'when sh! is not successful' do
    it "raises an exception" do
      capture_stdout do 
        expect {
          sh!("foo")
        }.to raise_error
      end
    end
  end
end

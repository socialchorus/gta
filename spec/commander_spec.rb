require 'spec_helper'

describe GTA::Commander do
  let(:commander) { GTA::Commander.new(command) }
  let(:log_path) { File.dirname(__FILE__) + "/../log/gta.log" }
  let(:log) { File.read(log_path) }

  before do
    File.delete(log_path) if File.exist?(log_path)
  end

  context 'when command is successful' do
    let(:command) { 'echo foo' }

    it "performs the command and returns the output" do
      capture_stdout do
        commander.perform.should == "foo\n"
      end
    end

    it "writes to the log" do
      capture_stdout do
        commander.perform
      end

      log.should include "foo"
    end
  end

  context 'when the command is not successful' do
    context 'with a bash error, that bubbles up to a Ruby error' do
      let(:command) { 'foo' }

      context 'when #perform! used' do
        it "raises an error when the #perform! method is called" do
          capture_stdout do
            expect {
              commander.perform!
            }.to raise_error
          end
        end
      end

      context 'when #perform is used' do
        it "sends outputs the message in red" do
          output = capture_stdout do
            commander.perform
          end
          output.should include(ANSI.red_on_black)
          output.should include("No such file or directory - foo")
        end

        it "returns the error message when the non-bang method is used" do
          capture_stdout do
            commander.perform.should == "No such file or directory - foo"
          end
        end

        it "writes to the log" do
          capture_stdout do
            commander.perform
          end

          log.should include "No such file or directory - foo"
        end
      end
    end
  end
end

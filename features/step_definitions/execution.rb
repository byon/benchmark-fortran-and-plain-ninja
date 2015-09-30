require 'open3'

module Execution
  def generate
    expect_to_succeed(generation_command)
  end

  def build
  end

  def execute
    # @todo
  end

  private

  def expect_to_succeed(command, execution_directory=".")
    Open3.popen2e(*command, :chdir=>execution_directory) do |_, output, thread|
      result = thread.value.exitstatus
      message = command_failed_message(command[0], result, output.read)
      assert_equal 0, result, message
    end
  end

  def generation_command
    # @todo pass the configuration
    return ["build/debug/generate.exe"]
  end

  def command_failed_message(command, status, output)
    separator = '-------------'
    "Command #{command} failed with error code #{status} and output\n" +
      "#{separator}\n#{output}#{separator}"
  end
end

World(Execution)

require 'open3'

module Execution
  def generate
    expect_to_succeed(generation_command)
  end

  def build
    ensure_build_directory_exists
    expect_to_succeed(build_command, 'generated')
  end

  def execute
    # @todo
  end

  def expect_to_succeed(command, execution_directory=".")
    Open3.popen2e(*command, :chdir=>execution_directory) do |_, output, thread|
      result = thread.value.exitstatus
      message = command_failed_message(command[0], result, output.read)
      assert_equal 0, result, message
    end
  end

  private

  def generation_command
    # @todo pass the configuration
    return ["build/debug/generate.exe"]
  end

  def build_command
    return ['ninja']
  end

  def command_failed_message(command, status, output)
    separator = '-------------'
    "Command #{command} failed with error code #{status} and output\n" +
      "#{separator}\n#{output}#{separator}"
  end

  def ensure_build_directory_exists
    FileUtils::mkdir_p 'generated/build'
  end
end

World(Execution)

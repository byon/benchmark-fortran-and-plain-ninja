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
    @output_from_generated_exe = expect_to_succeed(generated_exe_command)
  end

  def output_from_generated_exe
    @output_from_generated_exe
  end

  def expect_to_succeed(command, execution_directory=".")
    Open3.popen2e(*command, :chdir=>execution_directory) do |_, output, thread|
      result = thread.value.exitstatus
      all_output = output.read
      message = command_failed_message(command[0], result, all_output)
      assert_equal 0, result, message
      return all_output
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

  def generated_exe_command
    return ["generated/build/debug/generated.exe"]
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

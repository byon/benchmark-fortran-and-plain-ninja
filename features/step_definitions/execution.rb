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
    result, output = execute_command(command, execution_directory)
    assert_equal 0, result, command_failed_message(command[0], result, output)
    return output
  end

  def generate_and_store_result
    @generation_result, @generation_output = execute_command(generation_command)
  end

  def generation_try_result
    @generation_result
  end

  def generation_try_output
    @generation_output
  end

  private

  def generation_command
    result = ["build/debug/generate.exe"]
    result << "#{@generated_components}" if @generated_components
    result << "#{@generated_files}" if @generated_files
    result << "#{@generated_rows}" if @generated_rows
    return result
  end

  def build_command
    return ['ninja']
  end

  def generated_exe_command
    return ["generated/build/debug/generated.exe"]
  end

  def execute_command(command, execution_directory=".")
    Open3.popen2e(*command, :chdir=>execution_directory) do |_, output, thread|
      result = thread.value.exitstatus
      return [result, output.read]
    end
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

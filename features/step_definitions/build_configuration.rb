module BuildConfiguration

  def required_ninja_version
    find_assignment('ninja_required_version', 'required version for ninja')
  end

  def build_directory_root
    find_assignment('builddir', 'build directory root')
  end

  def build_configuration
    find_assignment('configuration', 'build configuration')
  end

  def build_output_directory
    find_assignment('output_directory', 'output directory')
  end

  def compilation_options
    find_assignment('fflags', 'compilation options').scan(/(?:[^\s"]|"[^"]*")+/)
  end

  private

  def find_assignment(id, name)
    match = read_build_configuration.match(/#{id} = (.*)/)
    assert match, "Could not find #{name}"
    return match.captures[0]
  end

  def read_build_configuration
    @configuration ||= build_configuration_file.read.gsub(/\r/, '')
  end

  def build_configuration_file
    File.open('generated/build.ninja')
  end
end

World(BuildConfiguration)

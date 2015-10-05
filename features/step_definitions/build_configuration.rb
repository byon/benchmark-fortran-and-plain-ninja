module BuildConfiguration

  def required_ninja_version
    find_assignment('ninja_required_version', 'required version for ninja')
  end

  def build_directory_root
    find_assignment('builddir', 'build directory root')
  end

  private

  def find_assignment(id, name)
    match = build_configuration.match(/#{id} = (.*)/)
    assert match, "Could not find #{name}"
    return match.captures[0]
  end

  def build_configuration
    @configuration ||= build_configuration_file.read.gsub(/\r/, '')
  end

  def build_configuration_file
    File.open('generated/build.ninja')
  end
end

World(BuildConfiguration)

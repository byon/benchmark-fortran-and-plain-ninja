
Given(/^any valid configuration$/) do
  create_valid_configuration
end

When(/^files are generated$/) do
  generate
end

When(/^generated files are built$/) do
  generate
  build
end

Then(/^there is a file "([^"]*)"$/) do |file|
  assert File.exists? file
end

Then(/^file "([^"]*)" defines program "([^"]*)"$/) do |path, program|
  text = File.open(path).read
  assert_match(/program #{program}/, text, 'program start is not defined')
  assert_match(/end program/, text, 'program end is not defined')
end

Then(/^build configuration file requires ninja version "([^"]*)"$/) do |version|
  assert_equal(version, required_ninja_version)
end

Then(/^build configuration file sets build directory root to "([^"]*)"$/) do |directory|
  assert_equal(directory, build_directory_root)
end

Then(/^build configuration file sets configuration to "([^"]*)"$/) do |expected|
  assert_equal(expected, build_configuration)
end

Then(/^build configuration file sets output directory to "([^"]*)"$/) do |directory|
  assert_equal(directory, build_output_directory)
end

Then(/^compilation options include "(.*)"$/) do |option|
  assert_includes(compilation_options, option)
end

Then(/^build configuration rule "([^"]*)" defines fortran compilation$/) do |rule|
  command = build_rules(rule).get_declaration('command')
  assert_equal(command, 'ifort $fflags $in /object:$out')
end

Then(/^build configuration is set to compile "([^"]*)"$/) do |target|
  edge = build_edges_by_input(target)
  assert_equal('fc', edge.rule)
  assert_equal([expected_object_path(target)], edge.outputs)
end

def expected_object_path(fortran_path)
  object_file = File.basename(fortran_path, File.extname(fortran_path)) + '.obj'
  '$output_directory/' + object_file
end

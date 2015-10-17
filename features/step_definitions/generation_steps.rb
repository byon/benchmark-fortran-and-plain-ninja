
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
  assert File.exists?(file), "File '#{file} does not exist"
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

Then(/^"([^"]*)" is dependent on "([^"]*)"$/) do |dependant, source|
  edge = build_edges_by_input(dependant)
  assert_equal('fc', edge.rule)
  assert_equal([expected_object_path(source)], edge.implicit_dependencies)
end

def expected_object_path(fortran_path)
  object_file = File.basename(fortran_path, File.extname(fortran_path)) + '.obj'
  '$output_directory/' + object_file
end

Then(/^linking options include "([^"]*)"$/) do |option|
  assert_includes(linking_options, option)
end

Then(/^build configuration rule "([^"]*)" defines fortran linking$/) do |rule|
  command = build_rules(rule).get_declaration('command')
  assert_equal(command, 'link /OUT:$out $ldflags $in')
end

Then(/^build configuration is set to link "([^"]*)"$/) do |target|
  edge = build_edges_by_target(target)
  assert_equal('flink', edge.rule)
  assert_equal([target], edge.outputs)
end

Then(/^build configuration will link object "([^"]*)"$/) do |object_file|
  edge = build_edges_by_target('$output_directory/generated.exe')
  assert_includes(edge.explicit_dependencies, object_file)
end

Then(/^executing "([^"]*)" results in a success$/) do |path|
  expect_to_succeed([path])
end

When(/^executable built from generated files is executed$/) do
  generate
  build
  execute
end

Then(/^output contains print\-line from "([^"]*)"$/) do |expected|
  assert_match(/#{expected}/, output_from_generated_exe)
end

Given(/^count of files in component is (\d+)$/) do |count|
  set_file_count_to(count)
end

Then(/^component should have (\d+) files generated$/) do |count|
  assert_equal count.to_i, generated_files_in_component?('A').size
end

Then(/^"([^"]*)" should contain module "([^"]*)"$/) do |path, expected|
  assert_equal expected, read_module_from_file(path)
end

Then(/^"([^"]*)" should contain subroutine "([^"]*)"$/) do |path, expected|
  assert_equal expected, read_subroutine_from_file(path)
end

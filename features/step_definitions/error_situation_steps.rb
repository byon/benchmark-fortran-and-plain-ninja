Given(/^a missing file count$/) do
  create_configuration_where_file_count_is_missing
end

When(/^file generation is tried$/) do
  generate_and_store_result
end

Then(/^generation failed because of "([^"]*)"$/) do |expected_reason|
  assert_equal 1, generation_try_result
  assert_match(/#{expected_reason}/, generation_try_output)
end

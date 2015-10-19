Given(/^a missing file count$/) do
  create_configuration_with_missing_file_count
end

Given(/^a missing row count$/) do
  create_configuration_with_missing_row_count
end

When(/^file generation is tried$/) do
  generate_and_store_result
end

Then(/^generation failed because of "([^"]*)"$/) do |expected_reason|
  assert_equal 1, generation_try_result
  assert_match(/#{expected_reason}/, generation_try_output)
end

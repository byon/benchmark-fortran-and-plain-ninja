Feature: Configuring generation size

  Scenario Outline: configuring count of files in a component
    Given count of files in component is <number>
    When files are generated
    Then component should have <number> files generated

    Examples:
    | number |
    |      1 |
    |      2 |
    |     10 |

  Scenario: configuring building of files in a component
    Given count of files in component is 2
    When files are generated
    Then build configuration is set to compile "A_1.f90"

  Scenario: configuring dependency to files in component
    Given count of files in component is 2
    When files are generated
    Then "A_main.f90" is dependent on "A_1.f90"

  Scenario: Linking executable will include the object files
    Given count of files in component is 2
    When files are generated
    And build configuration will link object "$output_directory/A_1.obj"

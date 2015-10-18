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

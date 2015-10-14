Feature: Configuring generation size

  Scenario Outline: configuring count of files in a component
    Given count of files in component is <number>
    When files are generated
    Then component should have <number> files generated

    Examples:
    | number |
    |      1 |

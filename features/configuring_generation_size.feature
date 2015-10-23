Feature: Configuring generation size

  Scenario Outline: configuring count of files in a component
    Given any valid configuration
    And count of files in component is <number>
    When files are generated
    Then component should have <number> files generated

    Examples:
    | number |
    |      1 |
    |      2 |
    |     10 |

  Scenario: configuring building of files in a component
    Given any valid configuration
    And count of files in component is 2
    When files are generated
    Then build configuration is set to compile "A_1.f90"

  Scenario: configuring dependency to files in component
    Given any valid configuration
    And count of files in component is 2
    When files are generated
    Then "A_main.f90" is dependent on "A_1.f90"

  Scenario Outline: configuring count of rows in component files
    Given any valid configuration
    And count of files in component is 2
    And count of rows in component files is <number>
    When files are generated
    Then "generated/A_1.f90" should contain <number> fill lines

    Examples:
    | number |
    |      1 |
    |      2 |
    |     10 |

  Scenario Outline: configuring count of files in a component
    Given any valid configuration
    And count of components is <number>
    When generated files are built
    Then there should be <number> components

    Examples:
    | number |
    |      1 |
    |      2 |

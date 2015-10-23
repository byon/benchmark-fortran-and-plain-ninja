@performance
Feature: performance

  Scenario Outline: ensuring that larger configurations work
    Given any valid configuration
    And count of components is <components>
    And count of files in component is <files>
    And count of rows in component files is <rows>
    When executable built from generated files is executed
    Then output contains print-line from "main.f90"

    # Note: Currently there can be maximum of 26 components, because
    # the module names are one character identifiers. 26 will result
    # in the last character 'X'.
    # For the purposes of this experiment, I can't be bothered to write
    # more advanced naming logic.

    Examples:
    | components | files |   rows |
    |          1 |     1 | 100000 |
    |          1 |   100 |      1 |
    |         26 |     1 |      1 |

@performance
Feature: performance

  Scenario Outline: ensuring that larger configurations work
    Given any valid configuration
    And count of files in component is <files>
    And count of rows in component files is <rows>
    When executable built from generated files is executed
    Then output contains print-line from "main.f90"

    Examples:
    | files |   rows |
    |     1 | 100000 |
    |   100 |      1 |

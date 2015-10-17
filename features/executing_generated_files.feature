Feature: Building generated files

  Background:
    Given any valid configuration
    When executable built from generated files is executed

  Scenario: Main program is executed
    Then output contains print-line from "main.f90"

  Scenario: Component is executed
    Then output contains print-line from "A_1.f90"

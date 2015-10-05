Feature: Generating files

  Background:
    Given any valid configuration
    When files are generated

  Scenario: Generating main fortran file
    Then there is a file "generated/main.f90"

  Scenario: Main file contains fortran program
    Then file "generated/main.f90" defines program "generate"

  Scenario: Generating build configuration file
    Then there is a file "generated/build.ninja"

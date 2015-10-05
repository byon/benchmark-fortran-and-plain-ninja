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

  Scenario: Build configuration file defines minimum ninja version
    Then build configuration file requires ninja version "1.6.0"

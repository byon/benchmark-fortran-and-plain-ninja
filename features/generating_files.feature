Feature: Generating files

  Scenario: Generating main fortran file
    Given any valid configuration
    When files are generated
    Then there is a file "generated/main.f90"

  Scenario: Main file contains fortran program
    Given any valid configuration
    When files are generated
    Then file "generated/main.f90" defines program "generate"

Feature: Generating files

  Scenario: Generating main fortran file
    Given any valid configuration
    When files are generated
    Then there is a file "generated/main.f90"

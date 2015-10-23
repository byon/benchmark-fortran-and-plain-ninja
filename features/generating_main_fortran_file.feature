Feature: Generating main fortran file

  Background:
    Given any valid configuration
    And count of components is 2
    When files are generated

  Scenario: Generating main fortran file
    Then there is a file "generated/main.f90"

  Scenario: Main file contains fortran program
    Then file "generated/main.f90" defines program "generate"

  Scenario: Main file calls components
    Then file "generated/main.f90" calls subroutine from component "A"
    And file "generated/main.f90" calls subroutine from component "B"

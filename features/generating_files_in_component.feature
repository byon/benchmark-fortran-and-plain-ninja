Feature: Generating files in a component

  Background:
    Given count of files in component is 2
    When files are generated

  Scenario: Generating main file module
    Then "generated/A_main.f90" should contain module "A"

  Scenario: Generating main file public function
    Then "generated/A_main.f90" should contain subroutine "call_A"

  Scenario: Generating main file print lines
    Then "generated/A_main.f90" should contain print line

  Scenario: Generating additional file module
    Then "generated/A_1.f90" should contain module "A_1"

  Scenario: Generating additional file public function
    Then "generated/A_1.f90" should contain subroutine "call_A_1"

  Scenario: Generating additional file print lines
    Then "generated/A_1.f90" should contain print line

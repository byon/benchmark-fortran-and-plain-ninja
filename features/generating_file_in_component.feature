Feature: Generating file in a component

  Background:
    Given count of files in component is 1
    When files are generated

  Scenario: Generating module
    Then "generated/A_1.f90" should contain module "A"

  Scenario: Generating public function
    Then "generated/A_1.f90" should contain subroutine "call_A"

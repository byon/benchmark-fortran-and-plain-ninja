Feature: Generating file in a component

  Scenario: Generating module
    Given count of files in component is 1
    When files are generated
    Then "generated/A_1.f90" for component should contain module "A"

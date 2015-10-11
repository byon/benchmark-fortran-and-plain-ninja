Feature: Building generated files

  Scenario: Building main object file
    Given any valid configuration
    When generated files are built
    Then there is a file "generated/build/debug/main.obj"

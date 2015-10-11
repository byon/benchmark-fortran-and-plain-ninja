Feature: Building generated files

  Background:
    Given any valid configuration
    When generated files are built

  Scenario: Building main object file
    Then there is a file "generated/build/debug/main.obj"

  Scenario: Building executable
    Then there is a file "generated/build/debug/generated.exe"

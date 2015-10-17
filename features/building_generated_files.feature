Feature: Building generated files

  Background:
    Given any valid configuration
    When generated files are built

  Scenario: Building main object file
    Then there is a file "generated/build/debug/main.obj"

  Scenario: Building component object files
    Then there is a file "generated/build/debug/A_1.obj"

  Scenario: Building executable
    Then there is a file "generated/build/debug/generated.exe"

  Scenario: Executable can actually be executed
    Then executing "generated/build/debug/generated.exe" results in a success

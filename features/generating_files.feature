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

  Scenario: Build configuration file defines build directory root
    Then build configuration file sets build directory root to "build"

  Scenario: Build configuration file targets debug build
    Then build configuration file sets configuration to "debug"

  Scenario: Build configuration file defines output_directory
    Then build configuration file sets output directory to "$builddir/$configuration"

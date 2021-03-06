Feature: Error situations

  Scenario Outline: Missing configuration option
    Given a missing <configuration>
    When file generation is tried
    Then generation failed because of "<error>"

    Examples:
    | configuration   | error                   |
    | component count | missing component count |
    | file count      | missing file count      |
    | row count       | missing row count       |

Feature: Error situations

  Scenario: Missing file count is an error
    Given a missing file count
    When file generation is tried
    Then generation failed because of "missing file count"

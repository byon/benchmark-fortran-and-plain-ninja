module Configuration
  def create_valid_configuration
    @generated_files = 1
    @generated_rows = 1
  end

  def create_configuration_with_missing_file_count
    @generated_files = nil
    @generated_rows = nil
  end

  def create_configuration_with_missing_row_count
    # This is not _really_ a good test implementation, mainly because
    # all of the command line arguments are just integers without
    # identifiers. This means it is impossible to really know, which
    # integer is inteded for which purpose.
    # However, I won't bother to implement option parser in Fortran...
    @generated_files = 1
    @generated_rows = nil
  end

  def set_file_count_to(count)
    @generated_files = count
  end

  def set_row_count_to(count)
    @generated_rows = count
  end
end

World(Configuration)

module Configuration
  def create_valid_configuration
    @generated_files = 1
  end

  def create_configuration_where_file_count_is_missing
    @generated_files = nil
  end
end

World(Configuration)

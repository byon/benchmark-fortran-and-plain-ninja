module GeneratedFiles
  def generated_source_files?
    Dir.glob('generated/*.f90')
  end

  def generated_files_in_component?(component)
    generated_source_files?.select {|f| f=~ /#{component}_.*\.f90/}
  end

end

World(GeneratedFiles)

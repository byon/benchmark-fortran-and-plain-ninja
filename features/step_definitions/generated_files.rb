module GeneratedFiles
  def generated_source_files?
    Dir.glob('generated/*.f90')
  end

  def generated_files_in_component?(component)
    generated_source_files?.select {|f| f=~ /#{component}_.*\.f90/}
  end

  def read_module_from_file(path)
    contents = open(path).readlines
    module_lines = contents.grep(/^(end )*module/)
    assert_equal 2, module_lines.size(), "#{path} does not define module"
    module_match = module_lines[0].match(/module (\w+)/)
    assert module_match, "#{path} does not define module"
    assert_match(/end module/, module_lines[1])
    return module_match.captures[0]
  end
end

World(GeneratedFiles)

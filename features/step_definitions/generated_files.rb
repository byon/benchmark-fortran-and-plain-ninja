module GeneratedFiles
  def generated_source_files?
    Dir.glob('generated/*.f90')
  end

  def generated_files_in_component?(component)
    generated_source_files?.select {|f| f=~ /#{component}_.*\.f90/}
  end

  # Note: the parsing in these helpers is fragile and cumbersome. But
  # implementing an actual parser would be too much effort for
  # purposes of this project (just generating fortran for the sake of
  # lines of code)

  def read_module_from_file(path)
    read_scope_from_file(path, 'module')
  end

  def read_subroutine_from_file(path)
    read_scope_from_file(path, 'subroutine')
  end

  def read_subroutine_lines(path, subroutine_name)
    read_lines_between(path, "subroutine #{subroutine_name}", 'end subroutine')
  end

  private

  def read_scope_from_file(path, identifier)
    contents = open(path).readlines
    scope_lines = contents.grep(/^(end )*\b#{identifier}\b/)
    assert_equal 2, scope_lines.size(), "#{path} does not define #{identifier}"
    scope_match = scope_lines[0].match(/#{identifier} (\w+)/)
    assert scope_match, "#{path} does not define #{identifier}"
    assert_match(/end #{identifier}/, scope_lines[1])
    return scope_match.captures[0]
  end

  def read_lines_between(path, start, stop)
    result = []
    is_in_between = false
    open(path).each_line do |line|
      if line =~ /#{start}/
        is_in_between = true
        next
      end
      if line =~ /#{stop}/
        assert is_in_between, "Found #{stop} before #{start}"
        return result
      end
      result << line.gsub(/[\r\n]/, '') if is_in_between
    end
    assert is_in_between, "Neither #{stop} or #{start} is defined"
    flunk "Did not find #{stop}"
  end
end

World(GeneratedFiles)

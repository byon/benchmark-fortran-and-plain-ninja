module BuildConfiguration

  def required_ninja_version
    find_assignment('ninja_required_version', 'required version for ninja')
  end

  def build_directory_root
    find_assignment('builddir', 'build directory root')
  end

  def build_configuration
    find_assignment('configuration', 'build configuration')
  end

  def build_output_directory
    find_assignment('output_directory', 'output directory')
  end

  def compilation_options
    find_assignment('fflags', 'compilation options').scan(/(?:[^\s"]|"[^"]*")+/)
  end

  def build_rules(identifier)
    rules = find_rules
    assert(rules.key?(identifier), "there is no build rule '#{identifier}'")
    rules[identifier]
  end

  def build_edges_by_input(input)
    edges = find_edges
    result = edges.detect { |e| e.explicit_dependencies.include? input}
    assert(result, "Could not find build edge with input #{input}")
    return result
  end

  class Rule
    attr_reader :name
    def initialize(name)
      @name = name
      @declarations = {}
    end

    def add_declaration(line)
      name, value = line.split('=', 2).collect(&:strip)
      @declarations[name] = value
    end

    def get_declaration(id)
      unless @declarations.key?(id)
        # @todo See if you can get minitest assertions to work here
        raise "rule #{@name} has no declaration '#{id}'"
      end
      @declarations[id]
    end
  end

  class BuildEdge
    attr_reader :outputs
    attr_reader :rule
    attr_reader :explicit_dependencies
    attr_accessor :implicit_dependencies
    attr_accessor :order_only_dependencies

    def initialize(outputs, rule, excplicit_dependencies)
      @outputs = outputs
      @rule = rule
      @explicit_dependencies = excplicit_dependencies
      @implicit_dependencies = implicit_dependencies
      @order_only_dependencies = order_only_dependencies
    end
  end

  private

  def find_assignment(id, name)
    match = read_build_configuration.match(/#{id} = (.*)/)
    assert match, "Could not find #{name}"
    return match.captures[0]
  end

  def read_build_configuration
    @configuration ||= build_configuration_file.read.gsub(/\r/, '')
  end

  def build_configuration_file
    File.open('generated/build.ninja')
  end

  def find_rules
    # This is a rather crappy and fragile algorithm to parse the
    # rules. But I cannot be bothered to write a real parser.
    result = {}
    rule = nil
    read_build_configuration.each_line do |line|
      if not rule
        if match = line.match(/^rule (\w+)/)
          rule_id = match.captures[0]
          rule = Rule.new(rule_id)
        end
      else
        if line.include? '='
          rule.add_declaration(line)
        else
          assert_match(/^ *$/, line,
                       "Rule #{rule.name} should end into empty line")
          result[rule.name] = rule
          rule = nil
        end
      end
    end
    result[rule.name] = rule if rule
    return result
  end

  def find_edges
    edges = read_build_configuration.each_line.select { |l| l =~/^build / }
    edges.map {|e| parse_edge(e) }
  end

  def parse_edge(edge_line)
    edge = parse_mandatory_parts_of_an_edge(edge_line)
    edge.implicit_dependencies = parse_implicit_dependencies(edge_line)
    edge.order_only_dependencies = parse_order_only_dependencies(edge_line)
    return edge
  end

  def parse_mandatory_parts_of_an_edge(edge_line)
    match = edge_line.match(/build\s+([^:]+)\s*:\s*(\w+)\s+(.+)\s*\|?/)
    assert(match, "edge #{edge_line} is missing rule or explicit dependencies")
    outputs, rule, explicit_dependencies = match.captures
    return BuildEdge.new(outputs.split, rule, explicit_dependencies.split)
  end

  def parse_implicit_dependencies(edge_line)
    match = edge_line.match(/\|\s*(.+)\s*\|\|/)
    match ? match.captures[0].split : []
  end

  def parse_order_only_dependencies(edge_line)
    match = edge_line.match(/\|\|\s*(.+)\s*$/)
    match ? match.captures[0].split : []
  end

  def dependence_expression()
    outputs = /([^: ]+)/
    rule = /(\w+)/
    explicit = /([^|]+)/
    implicit = /(.*)+/
    order_only = /(.*)+/
    dependencies = /#{explicit} *\| *#{implicit} *\|\| *#{order_only}/
    /^build +#{outputs} *: *#{rule} +#{dependencies} */
  end
end

World(BuildConfiguration)

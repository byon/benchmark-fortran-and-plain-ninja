require 'fileutils'
require 'minitest/spec'

class MinitestWorld
  extend Minitest::Assertions
  attr_accessor :assertions

  def initialize
    self.assertions = 0
  end
end

Before do
  FileUtils.rm_rf 'generated'
end

After do
  FileUtils.rm_rf 'generated'
end

World do
  MinitestWorld.new
end

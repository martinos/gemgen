$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/unit'
require 'minitest/autorun'
require 'fileutils'

module Gemgen
  class MiniTest::Unit::TestCase
    include FileUtils
    def tmp_dir
      File.expand_path('../../tmp', __FILE__)
    end

    def local_io(in_str = "")
      old_stdin, old_stdout = $stdin, $stdout
      $stdin = StringIO.new(in_str)
      $stdout = StringIO.new
      yield
      out_str = $stdout.string
      $stdin, $stdout = old_stdin, old_stdout
      out_str
    end
  end
end

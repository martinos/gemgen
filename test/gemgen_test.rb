require 'test_helper'
require 'gemgen/generator'

module Gemgen
  class GemgenTest < MiniTest::Unit::TestCase
    def setup
      if File.exist? tmp_dir
        rm_rf tmp_dir
      end
      mkdir tmp_dir
    end

    def test_that_minitest_unit_tests_runs
      gem_name = 'minitest_unit'
      Dir.chdir(tmp_dir) do |dir|
        @cli = Gemgen::Generator.new([gem_name])
        @cli.invoke_all
        Dir.chdir(gem_name) do
          output = `bundle exec rake`
          assert_match /1 tests, 1 assertions, 0 failures, 0 errors, 0 skips/, output
        end
      end
    end
  end 
end

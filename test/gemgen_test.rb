require 'test_helper'
require 'gemgen/generator'

module Gemgen
  class GemgenTest < MiniTest::Unit::TestCase
    def test_minitest_unit
      if File.exist? tmp_dir
        rm_rf tmp_dir
      end
      mkdir tmp_dir
      Dir.chdir(tmp_dir) do |dir|
        @cli = Gemgen::Generator.new(['tata'])
        @cli.invoke_all
        Dir.chdir('tata') do
          raise "rake test execution failed" unless system("bundle exec rake") 
        end
      end
    end
  end 
end

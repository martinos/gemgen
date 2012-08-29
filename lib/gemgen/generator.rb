require 'thor/group'

module Gemgen
  class Generator < Thor::Group
    include Thor::Actions

    # Define arguments and options
    argument :gem_name
    class_option :test_framework, :default => :mini_test
    class_option :test_type, :default => "unit"

    def self.source_root
      File.expand_path(File.dirname(__FILE__) +'/templates')
    end
    
    def run_bundle_gem
      run "bundle gem #{gem_name}", :verbose => true
      commit "$> bundle gem #{gem_name}"
    end

    def fix_already_initialized_constant_version_warning
      inside gem_name do
        sub_str = "$:.unshift File.expand_path('../lib', __FILE__)\nrequire '#{gem_name}/version'"
        gsub_file "#{gem_name}.gemspec", /^.*version', __FILE__.*$/, sub_str
      end
      commit "Fix already initialized constant VERSION warning"
    end

    def add_test_dependencies
      inside gem_name do
        insert_into_file "#{gem_name}.gemspec", :after => /gem.version.*\n/ do
          str = <<EOF
  # gem.add_dependency "put dependency here"
  gem.add_development_dependency 'rake'
  gem.add_development_dependency "bundler", "~> 1.0"
  gem.add_development_dependency 'minitest'
EOF
        end
      end
      bundle
      commit('Add testing gem dependencies')
    end

    def adding_test_tasks
      remove_file("#{gem_name}/Rakefile")
      template('Rakefile.tt', "#{gem_name}/Rakefile")
      commit "Add test tasks"
    end

    def create_test_files
      if options[:test_type] == "spec"
        test_path = "#{gem_name}/spec"
        create_file  test_path + "/spec_helper.rb" do
          spec_helper_content(gem_name)
        end 
        create_file test_path + "/#{gem_name}_spec.rb" do 
          spec_file_content(module_name)
        end
      else
        test_path = "#{gem_name}/test"
        create_file  test_path + "/test_helper.rb" do
          test_helper_content
        end 
        create_file test_path + "/#{gem_name}_test.rb" do 
          test_file_content(module_name, 'test_helper.rb')
        end
      end
      commit("Create test scaffold file")
    end

    def debug_gems_to_Gemfile
      remove_file("#{gem_name}/Gemfile")
      template('Gemfile.tt', "#{gem_name}/Gemfile")
      bundle
      commit "Add debug gems to Gemfile"
    end

    private

    def commit(msg)
      inside gem_name do 
        run "git add ."
        run "git commit -m '#{msg}'"
      end
    end

    def bundle
      inside gem_name do 
        run "bundle install"
      end
    end

    def module_name
      Thor::Util.camel_case(gem_name)
    end
    
    def test_type
      @test_type ||= options[:test_type].to_s == "spec" ? :spec : :test
    end
    
    def spec_helper_content(gem_name)
      _ = <<EOF
$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require '#{gem_name}'
require 'minitest/spec'
require 'minitest/autorun'

module SpecHelper
end
EOF
    end
    
    def test_helper_content
      _ = <<EOF
$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/unit'
require 'minitest/autorun'
EOF
    end
    
    def test_file_content(module_name, helper_file)
      _ = <<EOF
require '#{File.basename(helper_file, ".rb")}'

module #{module_name}
  class #{module_name}Test < MiniTest::Unit::TestCase
    def test_truth
      assert true 
    end
  end 
end
EOF
    end
    
    def spec_file_content(module_name)
      _ = <<EOF
require File.expand_path('../spec_helper', __FILE__)
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

include SpecHelper

describe #{module_name} do
  before do
  end

  it "should test truth" do
    true.must_equal true
  end
end
EOF
    end
  end
end
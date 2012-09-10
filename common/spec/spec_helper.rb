if ENV['COVERAGE_REPORTS']
  require 'tmpdir'
  require 'pp'
  require 'simplecov'

  SimpleCov.root(File.join(File.dirname(__FILE__), "../../"))
  SimpleCov.coverage_dir("common/coverage")

  SimpleCov.start do
    # Exclude averthing but the JSON Model code
    add_filter "test_utils.rb"
    add_filter "schema/"
    add_filter "backend"
    add_filter "config"

    # Leave gems out too
    add_filter "build/gems"
  end
  
  env_coverage_reports_tmp = ENV['COVERAGE_REPORTS'].clone
  
  ENV['COVERAGE_REPORTS'] = nil
  
end


require_relative '../../backend/spec/spec_helper'


if env_coverage_reports_tmp
  ENV['COVERAGE_REPORTS'] = env_coverage_reports_tmp
end
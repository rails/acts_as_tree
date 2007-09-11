$:.unshift(File.dirname(__FILE__) + '/../../../rails/activesupport/lib')
$:.unshift(File.dirname(__FILE__) + '/../../../rails/activerecord/lib')
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'
require 'acts_as_tree'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])

load(File.dirname(__FILE__) + "/schema.rb") if File.exist?(File.dirname(__FILE__) + "/schema.rb")

class Test::Unit::TestCase #:nodoc:
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/" 
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  def create_fixtures(*table_names, &block)
    Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures/", table_names, {}, &block)
  end
  
  def assert_queries(num = 1)
    $query_count = 0
    yield
  ensure
    assert_equal num, $query_count, "#{$query_count} instead of #{num} queries were executed."
  end
  
  def assert_no_queries(&block)
    assert_queries(0, &block)
  end
  
end

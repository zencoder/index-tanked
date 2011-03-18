require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'active_record'
require 'sqlite3'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
require 'index_tanked'
require 'person'

class Test::Unit::TestCase
  
end

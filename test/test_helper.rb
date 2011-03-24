require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'active_record'
require 'sqlite3'
require 'webmock/test_unit'

WebMock.disable_net_connect!


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
require 'index-tanked'
require 'person'
require 'programmer'

class Test::Unit::TestCase
  include WebMock

end

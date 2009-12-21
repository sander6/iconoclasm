require 'rubygems'
require 'spec'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'iconoclast'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
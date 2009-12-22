require 'rubygems'
require 'spec'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'iconoclast'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

# It bothers me that mocha doesn't have this built-in.
# It also bothers me that I forked mocha but didn't add this.
# We are all at fault.
module Mocha
  class Expectation
    def throws(symbol, object = nil)
      @return_values += ReturnValues.new(SymbolThrower.new(symbol, object))
      self
    end
  end
  
  class SymbolThrower
    def initialize(symbol, object)
      @symbol = symbol
      @object = object
    end
    
    def evaluate
      @object ? throw(@symbol, @object) : throw(@symbol)
    end
  end
end
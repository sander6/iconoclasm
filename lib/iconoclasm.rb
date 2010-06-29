require 'rubygems'
require 'curb'

module Iconoclasm
  def self.version
    "1.0.8"
  end
end

$:.unshift(File.dirname(__FILE__))
require 'iconoclasm/downloader'
require 'iconoclasm/errors'
require 'iconoclasm/extractor'
require 'iconoclasm/favicon'
require 'iconoclasm/headers'

module Iconoclasm
  
  class << self
    include Iconoclasm::Extractor
    attr_accessor :timeout
    
    def extract(url, content = nil)
      Iconoclasm::Favicon.new(extract_favicon_from(url, content))
    end
  end
  
end

# For 1.8.6 compatibility.
class String
  def lines
    Enumerable::Enumerator.new(self.split("\n"))
  end
end unless ''.respond_to?(:lines)
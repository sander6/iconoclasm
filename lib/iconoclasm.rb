$:.unshift(File.dirname(__FILE__))
require 'iconoclasm/downloader'
require 'iconoclasm/errors'
require 'iconoclasm/extractor'
require 'iconoclasm/favicon'
require 'iconoclasm/headers'

module Iconoclasm
  
  class << self
    include Iconoclasm::Extractor
    
    def extract(url, content = nil)
      Iconoclasm::Favicon.new(extract_favicon_from(url, content))
    end
  end
  
end
$:.unshift(File.dirname(__FILE__))
require 'iconoclast/downloader'
require 'iconoclast/errors'
require 'iconoclast/extractor'
require 'iconoclast/favicon'
require 'iconoclast/headers'

module Iconoclast
  
  class << self
    include Iconoclast::Extractor
    
    def extract(url)
      Iconoclast::Favicon.new(extract_favicon_from(url))
    end
  end
  
end
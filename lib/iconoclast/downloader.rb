require 'curl'

module Iconoclast
  module Downloader

    @@user_agent = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'
    
    def self.user_agent=(agent)
      @@user_agent = agent
    end
    
    def self.user_agent
      @@user_agent
    end
    
    def get(url)
      Curl::Easy.http_get(url) do |curl|
        curl.headers['User-Agent']  = Iconoclast::Downloader.user_agent
        curl.follow_location        = true
      end
    end
    
    def head(url)
      Curl::Easy.http_head(url) do |curl|
        curl.headers['User-Agent']  = Iconoclast::Downloader.user_agent
      end
    end
    
  end
end
module Iconoclasm
  module Downloader

    @@user_agent = %Q{Mozilla/5.0 (compatible; Iconoclasm/#{Iconoclasm.version}; +http://github.com/sander6/iconoclasm)}
    
    def self.user_agent=(agent)
      @@user_agent = agent
    end
    
    def self.user_agent
      @@user_agent
    end
    
    def user_agent
      @@user_agent
    end
    
    def get(url)
      c = curl(url)
      c.http_get
      c
    end
    
    def head(url)
      c = curl(url)
      c.http_head
      c
    end
    
    private
    
    def curl(url)
      Curl::Easy.new(url) do |curl|
        curl.useragent        = user_agent
        curl.follow_location  = true
        curl.timeout          = Iconoclasm.timeout || 1000
      end
    end
  end
end

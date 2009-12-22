module Iconoclast

  class Error < StandardError
    def initialize(url)
      @url = url
    end
  end

  class MissingFavicon < Iconoclast::Error
    def message
      "#{@url} doesn't seem to have a favicon"
    end
  end
  
  class HTTPError < Iconoclast::Error
    def initialize(url, http_response)
      super(url)
      @response = http_response
    end
    
    def message
      "There was a problem getting #{@url} (#{http_error_reason})"
    end

    def http_error_message
      "#{@response.response_code}: #{http_error_reason}"
    end
    
    def http_error_reason
      @response.header_str[/(?<=\d{3}\s)(.*)$/].chomp
    end    
  end
  
  class RTFMError < Iconoclast::Error
    def initialize(reason)
      @reason = reason
    end
    
    def message
      "Iconoclast doesn't work that way (#{@reason})"
    end
  end
  
  class InvalidFavicon < Iconoclast::Error
    def initialize(url, content_type)
      super(url)
      @content_type = content_type
    end
    
    def message
      "The favicon from #{@url} is invalid (content type is #{@content_type})"
    end
  end
end
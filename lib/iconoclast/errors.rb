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
    def initialize(url, response)
      super(url)
      @response = response
    end
    
    def message
      msg = ""
      msg += "There was a problem getting #{@url} " if @url
      msg += "(#{http_error_reason})"
      msg
    end

    def code
      @response.respond_to?(:response_code) ? @response.response_code : @response[/\d{3}/]
    end

    def http_error_reason
      @response.respond_to?(:header_str) ? @response.header_str[/(?<=\d{3}\s)(.*)$/].chomp : @response
    end    

    def http_error_message
      "#{@code}: #{http_error_reason}"
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
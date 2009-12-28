module Iconoclasm

  class Error < StandardError
    def initialize(url)
      @url = url
    end
  end

  class MissingFavicon < Iconoclasm::Error
    def message
      "#{@url} doesn't seem to have a favicon"
    end
  end
  
  class HTTPError < Iconoclasm::Error
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
      @response.respond_to?(:header_str) ? error_reason : @response
    end

    def http_error_message
      "#{@code}: #{http_error_reason}"
    end
    
    private
    
    def error_reason
      first_line = @response.header_str.split('\n').first.chomp
      first_line.match(/\d{3}\s(.*)$/)
      $1
    end
  end
  
  class RTFMError < Iconoclasm::Error
    def initialize(reason)
      @reason = reason
    end
    
    def message
      "Iconoclasm doesn't work that way (#{@reason})"
    end
  end
  
  class InvalidFavicon < Iconoclasm::Error
    def initialize(url, content_type)
      super(url)
      @content_type = content_type
    end
    
    def message
      "The favicon from #{@url} is invalid (content type is #{@content_type})"
    end
  end
end
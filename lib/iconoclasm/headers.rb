module Iconoclasm
  class Headers

    attr_reader :version, :code, :message
    
    def initialize(header_string)
      parse_http_response(header_string.lines.first.chomp)
      @header_hash    = parse_header_string(header_string)
    end
    
    def [](header)
      @header_hash[convert_header_key(header.to_s)]
    end
    
    def content_type
      @content_type ||= self['content_type']
    end
    alias_method :type, :content_type
    
    def content_length
      @content_length ||= self['content_length']
    end
    alias_method :length, :content_length
    
    def location
      @location ||= self['location']
    end
    
    private
    
    def parse_header_string(header_string)
      header_string.scan(/^([^:]+):(.*)$/).inject({}) do |hash, (key, value)|
        hash.merge(convert_header_key(key) => convert_header_value(value))
      end
    end
    
    def convert_header_key(key)
      key.gsub(/-/, '_').downcase
    end
    
    def convert_header_value(value)
      if value =~ /^\s*\d+\s*$/
        value.to_i
      else
        value.strip
      end
    end
    
    def parse_http_response(response)
      if response.match(/HTTP\/(\d\.\d)\s*(\d{3})\s*(.*)/)
        @version  = $1
        @code     = $2.to_i
        @message  = $3.strip
      else
        raise Iconoclasm::HTTPError.new(nil, response)
      end
    end
  end
end
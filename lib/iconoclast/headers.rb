module Iconoclast
  class Headers
    
    def initialize(header_string)
      @http_response  = header_string.lines.first.chomp
      @header_hash    = parse(header_string)
    end
    
    def [](header)
      @header_hash[convert_header_key(header.to_s)]
    end
    
    def content_type
      @content_type ||= self['content_type']
    end
    
    def content_length
      @content_length ||= self['content_length']
    end
    alias_method :length, :content_length
    
    def location
      @location ||= self['location']
    end
    
    private
    
    def parse(header_string)
      header_string.scan(/^([\w-_]+):(.*)$/)inject({}) do |hash, (key, value)|
        hash.merge(convert_header_key(key) => convert_header_value(value))
      end
    end
    
    def convert_header_key(key)
      key.gsub(/-/, '_').downcase
    end
    
    def convert_header_value(value)
      if value =~ /^\d+$/
        value.to_i
      else
        value
      end
    end
    
  end
end
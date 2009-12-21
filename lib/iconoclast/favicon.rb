require 'tempfile'
require 'uri'

module Iconoclast
  class Favicon
    include Iconoclast::Downloader
    
    attr_reader :size, :content_type, :url

    def initialize(attributes = {})
      @url          = attributes[:url]
      @data         = attributes[:data]
      @name         = parse_name_from(@url)
      @headers      = attributes[:headers]
      @content_type = @headers.content_type
      @size         = @headers.content_length
      @save_path    = nil
    end
    
    def data
      @data ||= fetch_data
    end
    
    def valid?
      @valid ||= if size > 0
        case content_type
        when /^(?:x-)?image/ then true
        when /^text\/html/ then false
        when NilClass then false
        else
          # check the file type using filemagic, maybe?
          false
        end
      else
        false
      end
    end
    
    def fetch_data
      response = get(url)
      if response.response_code == 200
        response.body_str
      else
        raise Iconoclast::HTTPError.new(url, response)
      end
    end
    
    def save(path_or_storage = nil)
      @save_path = if path_or_storage.nil?
        save_to_tempfile
      elsif path_or_storage.is_a?(String) && File.exists?(path_or_storage)
        save_to_disk(path_or_storage)
      elsif path_or_storage.class.name == "AWS::S3::Bucket" # prevents us from having to require S3
        save_to_s3(path_or_storage)
      else
        raise Iconoclast::RTFMError.new("invalid storage type")
      end
    end
    
    def save_to_tempfile
      tfile = Tempfile.new(name)
      tfile.write(data)
      tfile.close
      tfile.path
    end

    def save_to_disk(path)
      path = "#{path}/#{name}" unless path.match(/\.[\w\d]{1,4}$/)
      file = File.new(path, File::CREAT|File::TRUNC|File::WRONLY)
      file.write(data)
      file.close
      path
    end
    
    def save_to_s3(s3)
      if s3.put(name, data)
        "#{s3.public_link}/#{name}"
      else
        raise Iconoclast::Error
      end
    end
    
    def parse_name_from(url)
      uri = URI.parse(url)
      uri.path.split('/').last
    end
  end
end
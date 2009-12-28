require 'tempfile'
require 'mime/types'
require 'uri'

module Iconoclasm
  class Favicon
    include Iconoclasm::Downloader
    
    attr_reader :content_type, :url, :save_path
    attr_accessor :name

    def initialize(attributes = {})
      @url          = attributes[:url]
      @data         = attributes[:data]
      @name         = attributes[:name]           || parse_name_from(@url)
      headers       = attributes[:headers]
      @content_type = attributes[:content_type]   ? attributes[:content_type] : headers ? headers.content_type : nil
      @size         = attributes[:content_length] ? attributes[:content_length] : headers ? headers.content_length : nil
      @save_path    = nil
    end
    
    def inspect
      "#<Iconoclasm::Favicon @url=#{url}, @name=#{name}, @content_type=#{content_type}, @size=#{size}, @save_path=#{save_path ? save_path : "nil"}>"
    end
    
    def size
      @size ||= data.size
    end
    alias_method :content_length, :size
    
    def data
      @data ||= fetch_data
    end
    
    def content_type
      if @content_type
        @content_type
      else
        mime = MIME::Types.of(name).first
        @content_type = mime.content_type if mime
      end
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
      if response.code == 200
        response.body
      else
        raise Iconoclasm::HTTPError.new(url, response)
      end
    end
    
    def save(path_or_storage = nil, force = false)
      if valid? && !force
        warn("Saving an invalid favicon.") if !valid? && force
        @save_path = if path_or_storage.nil?
          save_to_tempfile
        elsif path_or_storage.is_a?(String)
          save_to_file(path_or_storage)
        else
          raise Iconoclasm::RTFMError.new("invalid storage type")
        end
      else
        raise Iconoclasm::InvalidFavicon.new(url, content_type)
      end
    end
    
    def save_to_tempfile
      tfile = dump_data(Tempfile.new(name))
      @save_path = tfile.path
    end

    def save_to_file(path)
      path = File.expand_path(File.join(path, name))
      dump_data(File.new(path, File::CREAT|File::TRUNC|File::WRONLY))
      @save_path = path
    end
    
    def parse_name_from(url)
      URI.parse(url).path.split('/').last
    end
    
    def dump_data(file)
      file.write(data)
      file.close
      file
    end
  end
end
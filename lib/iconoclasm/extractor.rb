require 'nokogiri'
require 'addressable/uri'

module Iconoclasm
  module Extractor
    
    def self.included(base)
      base.class_eval { include Iconoclasm::Downloader }
    end
    
    def extract_favicon_from(url, content = nil)
      catch(:done) do
        extract_favicon_from_head_of(url, content)
        extract_favicon_from_naive_guess(base_url_of(url))
        raise Iconoclasm::MissingFavicon.new(url)
      end
    end
    
    private
    
    def extract_favicon_from_head_of(url, content = nil)
      if document = document_from(url, content)
        favicon_links = find_favicon_links_in(document)
        throw(:done, {
          :url          => href_of(favicon_links.first, :base_url => base_url_of(url)),
          :content_type => type_of(favicon_links.first)
        }) unless favicon_links.empty?
      end
    end

    def document_from(url, content = nil)
      if content
        Nokogiri::XML(content)
      else
        response = get(url)
        Nokogiri::XML(response.body_str) if response.response_code == 200
      end
    end
    
    def extract_favicon_from_naive_guess(base_url)
      naive_url = "#{base_url}/favicon.ico"
      response  = get(naive_url)
      headers   = Iconoclasm::Headers.new(response.header_str)
      if response.response_code == 200
        throw(:done, {
          :url            => naive_url,
          :content_length => headers.content_length,
          :content_type   => headers.content_type,
          :data           => response.body_str
        })
      end
    end
    
    def find_favicon_links_in(document)
      document.css('link:favicon_link', Class.new {
        def favicon_link(node_set)
          node_set.find_all { |node| node['rel'] && node['rel'] =~ /^(?:shortcut\s)?icon$/i }
        end
      }.new)
    end
    
    def base_url_of(url)
      uri = Addressable::URI.parse(url)
      "#{uri.scheme}://#{uri.host}"
    end
    
    def href_of(node, options = {})
      href = normal_node_attributes(node)['href']
      if href
        relative?(href.value) ? "#{options[:base_url]}#{href.value}" : href.value
      end
    end
    
    def relative?(href)
      href =~ /^[\.\/]/
    end
    
    def type_of(node)
      type = normal_node_attributes(node)['type']
      type.value if type
    end
    
    def normal_node_attributes(node)
      node.attributes.inject({}) { |hash, (key, value)| hash.merge(key.downcase => value) }
    end
  end
end
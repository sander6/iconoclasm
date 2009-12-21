require 'curl'
require 'nokogiri'
require 'uri'

module Iconoclast
  module Extractor
    
    def self.included(base)
      base.class_eval { include Iconoclast::Downloader }
    end
    
    def extract_favicon_from(url)
      catch(:done) do
        base_url  = base_url_of(url)
        extract_favicon_from_head_of(base_url)
        extract_favicon_from_naive_guess(base_url)
        raise Iconoclast::MissingFavicon.new(base_url)
      end
    end
    
    private
    
    def extract_favicon_from_head_of(base_url)
      response      = get(naive_url)
      if response.response_code == 200
        headers       = Iconoclast::Headers.new(response.header_str)
        document      = Nokogiri::XML(response.body_str)
        favicon_links = find_favicon_links_in(document)
        throw(:done, { :url => href_of(favicon_links.first), :headers => headers }) unless favicon_links.empty?
      end
    end
    
    def extract_favicon_from_naive_guess(base_url)
      naive_url = "#{base_url}/favicon.ico"
      response  = get(naive_url)
      headers   = Iconoclast::Headers.new(response.header_str)
      if response.response_code == 200
        throw(:done, { :url => naive_url, :headers => headers, :data => response.body_str })
      end
    end
    
    def find_favicon_links_in(document)
      document.xpath('//link[favicon_link(.)]', Class.new {
        def favicon_link(node_set)
          node_set.find_all { |node| node['rel'] && node['rel'] =~ /^(?:shortcut\s)?icon$/i }
        end
      }.new)
    end
    
    def base_url_of(url)
      uri = URI.parse(url)
      "#{uri.scheme}://#{uri.host}"
    end
    
    def href_of(node)
      href = node.attributes.inject({}) { |hash, (key, value)| hash.merge(key.downcase => value) }['href']
      href.value if href
    end
  end
end
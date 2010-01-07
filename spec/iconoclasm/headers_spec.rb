require File.expand_path(File.dirname(__FILE__) + '/../helper')

describe Iconoclasm::Headers do
  
  before do
    @http_response  = "HTTP/1.1 200 OK"
    @server         = "Apache/2.2.11 (Unix) mod_ssl/2.2.11 OpenSSL/0.9.7e"
    @last_modified  = "Wed, 13 Jun 2007 19:15:36 GMT"
    @content_type   = "image/x-icon"
    @content_length = 3638
    @header_string  = "#{@http_response}\r\nDate: Tue, 22 Dec 2009 21:15:31 GMT\r\nServer: #{@server}\r\nVary: Host,User-Agent\r\nLast-Modified: #{@last_modified}\r\nETag: \"e36-432ce70534600\"\r\nAccept-Ranges: bytes\r\nContent-Length: #{@content_length}\r\nContent-Type: #{@content_type}\r\n\r\n"
    @headers = Iconoclasm::Headers.new(@header_string)
  end
  
  describe "parsing the HTTP response" do
    
    it "should extract the HTTP version from the headers" do
      @headers.version.should == 1.1
    end
    
    it "should extract the HTTP response code from the headers" do
      @headers.code.should == 200
    end
    
    it "should extract the HTTP response message from the headers" do
      @headers.message.should == "OK"
    end
  end
  
  describe "hashifying the headers" do
    it "should allow headers to be accessible by name" do
      @headers['Server'].should == @server
    end
    
    it "should allow headers to be accessible by their normalized (lowercase and underscored) names" do
      @headers[:last_modified].should == @last_modified
    end
    
    it "should convert numeric values to actual numbers" do
      @headers[:content_length].should be_a_kind_of(Numeric)
    end
  end  
end
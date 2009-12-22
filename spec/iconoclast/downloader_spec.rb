require File.expand_path(File.dirname(__FILE__) + '/../helper')

describe Iconoclast::Downloader do

  before do
    class Thing; include Iconoclast::Downloader; end
    @thing  = Thing.new
    @url    = 'http://www.website.com'
    @curl   = mock('curl')
  end
  
  describe "GETting a url" do
    it "should GET the url using curl easy" do
      Curl::Easy.expects(:http_get).with(@url)
      @thing.get(@url)
    end
    
    it "should set the user agent to the default user agent" do
      @curl.stubs(:follow_location=)
      headers = mock('headers')
      Curl::Easy.stubs(:http_get).yields(@curl)
      @curl.expects(:headers).returns(headers)
      headers.expects(:[]=).with('User-Agent', Iconoclast::Downloader.user_agent)
      @thing.get(@url)
    end
    
    it "should follow redirects" do
      @curl.stubs(:headers).returns({})
      Curl::Easy.stubs(:http_get).yields(@curl)
      @curl.expects(:follow_location=).with(true)
      @thing.get(@url)
    end
  end
  
  describe "HEADing a url" do
    it "should HEAD the url using curl easy" do
      Curl::Easy.expects(:http_head).with(@url)
      @thing.head(@url)
    end
    
    it "should set the user agent to the default user agent" do
      headers = mock('headers')
      Curl::Easy.stubs(:http_head).yields(@curl)
      @curl.expects(:headers).returns(headers)
      headers.expects(:[]=).with('User-Agent', Iconoclast::Downloader.user_agent)
      @thing.head(@url)
    end
  end
end
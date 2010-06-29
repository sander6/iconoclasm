require File.expand_path(File.dirname(__FILE__) + '/../helper')

describe Iconoclasm::Downloader do

  before do
    class Thing; include Iconoclasm::Downloader; end
    @thing  = Thing.new
    @url    = 'http://www.website.com'
    @curl   = mock('curl')
  end
  
  describe "GETting a url" do
    it "should GET the url using Curl" do
      @thing.expects(:curl).with(@url).returns(@curl)
      @curl.expects(:http_get)
      @thing.get(@url)
    end    
  end
  
  describe "HEADing a url" do
    it "should HEAD the url using Curl" do
      @thing.expects(:curl).with(@url).returns(@curl)
      @curl.expects(:http_head)
      @thing.head(@url)
    end    
  end
  
  describe "building the Curl object" do
    before do
      Curl::Easy.expects(:new).with(@url).yields(@curl)
    end
    
    it "should set the user agent to the default user agent" do
      @curl.stubs(:follow_location=)
      @curl.stubs(:timeout=)
      @curl.expects(:useragent=).with(Iconoclasm::Downloader.user_agent)
      @thing.__send__(:curl, @url)
    end
    
    it "should follow location" do
      @curl.expects(:follow_location=).with(true)
      @curl.stubs(:timeout=)
      @curl.stubs(:useragent=)
      @thing.__send__(:curl, @url)
    end
    
    it "should set the timeout to 1 second" do
      @curl.stubs(:follow_location=)
      @curl.expects(:timeout=).with(1000)
      @curl.stubs(:useragent=)
      @thing.__send__(:curl, @url)
    end
  end
end
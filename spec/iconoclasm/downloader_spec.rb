require File.expand_path(File.dirname(__FILE__) + '/../helper')

describe Iconoclasm::Downloader do

  before do
    class Thing; include Iconoclasm::Downloader; end
    @thing  = Thing.new
    @url    = 'http://www.website.com'
    @curl   = mock('curl')
  end
  
  describe "GETting a url" do
    it "should GET the url using Typheous" do
      Typhoeus::Request.expects(:get).with(@url, instance_of(Hash))
      @thing.get(@url)
    end
    
    it "should set the user agent to the default user agent" do
      Typhoeus::Request.expects(:get).with(instance_of(String), has_entry(:user_agent => Iconoclasm::Downloader.user_agent))
      @thing.get(@url)
    end
    
    it "should follow redirects" do
      Typhoeus::Request.expects(:get).with(instance_of(String), has_entry(:follow_location => true))
      @thing.get(@url)
    end
  end
  
  describe "HEADing a url" do
    it "should HEAD the url using Typhoeus" do
      Typhoeus::Request.expects(:head).with(@url, instance_of(Hash))
      @thing.head(@url)
    end
    
    it "should set the user agent to the default user agent" do
      Typhoeus::Request.expects(:head).with(instance_of(String), has_entry(:user_agent => Iconoclasm::Downloader.user_agent))
      @thing.head(@url)
    end
  end
end
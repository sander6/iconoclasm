require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Iconoclast do
  
  describe "#extract" do
    before do
      @url = 'http://www.website.com/some-crappy-blog-post'
    end
    
    it "should extract the favicon for the given url" do
      Iconoclast.expects(:extract_favicon_from).with(@url, nil)
      Iconoclast::Favicon.stubs(:new)
      Iconoclast.extract(@url)
    end
    
    it "should make a new Favicon instance" do
      favicon = stub('favicon')
      Iconoclast.stubs(:extract_favicon_from).returns(favicon)
      Iconoclast::Favicon.expects(:new).with(favicon)
      Iconoclast.extract(@url)
    end
  end
  
end
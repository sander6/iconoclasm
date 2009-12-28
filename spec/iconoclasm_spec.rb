require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Iconoclasm do
  
  describe "#extract" do
    before do
      @url = 'http://www.website.com/some-crappy-blog-post'
    end
    
    it "should extract the favicon for the given url" do
      Iconoclasm.expects(:extract_favicon_from).with(@url, nil)
      Iconoclasm::Favicon.stubs(:new)
      Iconoclasm.extract(@url)
    end
    
    it "should make a new Favicon instance" do
      favicon = stub('favicon')
      Iconoclasm.stubs(:extract_favicon_from).returns(favicon)
      Iconoclasm::Favicon.expects(:new).with(favicon)
      Iconoclasm.extract(@url)
    end
  end
  
end
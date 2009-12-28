require File.expand_path(File.dirname(__FILE__) + '/../helper')

describe Iconoclasm::Extractor do
  
  before do
    class Thing; include Iconoclasm::Extractor; end
    @thing = Thing.new
  end
  
  describe "requiring the module" do
    it "should also require the Downloader module" do
      Thing.included_modules.should include(Iconoclasm::Downloader)
    end
  end
  
  describe "extracting a favicon from a url" do
    before do
      @url      = "http://www.website.com/page.html"
      @base_url = "http://www.website.com"
    end
    
    it "should try to find the favicon path in the head of the content" do
      @thing.expects(:extract_favicon_from_head_of).with(@url, nil).throws(:done)
      @thing.extract_favicon_from(@url)
    end
    
    describe "when the favicon path isn't in the head of the content" do
      before do
        @thing.stubs(:extract_favicon_from_head_of)
      end
      
      it "should naively guess where the favicon is" do
        @thing.expects(:extract_favicon_from_naive_guess).with(@base_url).throws(:done)
        @thing.extract_favicon_from(@url)
      end
    end
    
    describe "when the favicon isn't mentioned in the content or in the default place" do
      before do
        @thing.stubs(:extract_favicon_from_head_of)
        @thing.stubs(:extract_favicon_from_naive_guess)
      end
      
      it "should raise an error" do
        lambda { @thing.extract_favicon_from(@url) }.should raise_error(Iconoclasm::MissingFavicon)
      end
    end
  end
  
  describe "extracting a favicon from the head of some HTML content" do
    before do
      # stubbing this to make sure we're not calling it accidentally without
      # having to deal with expectations within a catch/throw pile
      @thing.stubs(:extract_favicon_from_naive_guess)
      @url      = "http://www.website.com/page.html"
      @base_url = "http://www.website.com"
      @content = <<-HTML
        <html>
          <head>
            <link rel="stylesheet" type="text/css" href="/stylesuponstyles.css" />
            <link rel="shortcut icon" type="image/vnd.microsoft.icon" href="/images/favicon.ico" />
          </head>
          <body>
            <p>This is the most interesting website ever.</p>
          </body>
        </html>
      HTML
    end
    
    describe "when content isn't already provided" do
      before do
        @response = mock('http response', :code => 200, :body => "")
      end
      
      it "should go get the content" do
        @thing.expects(:get).returns(@response)
        catch(:done) { @thing.__send__(:extract_favicon_from_head_of, @url) }
      end
    end

    describe "when content is provided" do
      describe "when there are no favicon links in the HTML content" do
        before do
          @thing.stubs(:find_favicon_links_in).returns([])
        end
        
        it "should return nil" do
          catch(:done) { @thing.__send__(:extract_favicon_from_head_of, @url, @content) }.should be_nil     
        end
      end
      
      describe "when there are some favicon links in the HTML content" do
        before do
          @link   = stub('favicon link')
          @links  = stub('favicon links', :empty? => false, :first => @link)
          @thing.stubs(:find_favicon_links_in).returns(@links)
        end
        
        describe "the return value" do
          before do
            @href = 'http://www.website.com/images/favicon.ico'
            @type = 'image/vnd.microsoft.icon'
            @thing.expects(:href_of).with(@link, instance_of(Hash)).returns(@href)
            @thing.expects(:type_of).with(@link).returns(@type)
            @hash = catch(:done) { @thing.__send__(:extract_favicon_from_head_of, @url, @content) } 
          end

          it "should contain the href from the first link" do
            @hash.should have_key(:url)
            @hash[:url].should == @href
          end
          
          it "should contain the content type from the first link" do
            @hash.should have_key(:content_type)
            @hash[:content_type].should == @type
          end
        end
      end
    end
  end
end
require File.expand_path(File.dirname(__FILE__) + '/../helper')

describe Iconoclasm::Favicon do

  before do
    @size       = 100
    @headers    = stub('headers', :content_type => 'image/vnd.microsoft.icon', :content_length => @size)
    @name       = 'favicon.ico'
    @url        = "http://www.website.com/#{@name}"
    @attributes = {
      :url      => @url,
      :headers  => @headers
    }
  end
  
  describe "initialization" do
    before do
      @favicon = Iconoclasm::Favicon.new(@attributes)
    end
    
    it "should set the content type to the content type supplied in the headers" do
      @favicon.content_type.should == @headers.content_type
    end
    
    it "should set the size to the content length supplied in the headers" do
      @favicon.size.should == @headers.content_length
    end
    
    it "should parse the name from the url supplied in the headers" do
      @favicon.name.should == @name
    end
    
    it "should not have a save path" do
      @favicon.save_path.should be_nil
    end    
  end
  
  describe "accessing the data attribute" do
    before do
      @data = "THIS IS TOTALLY SOME IMAGE DATA!"
    end
    
    describe "when the data was supplied on intialization" do
      before do
        @favicon = Iconoclasm::Favicon.new(@attributes.merge({:data => @data}))
      end
      
      it "should return the supplied data" do
        @favicon.data.should == @data
      end
    
      it "should not try to fetch the data from the internets" do
        @favicon.expects(:fetch_data).never
        @favicon.data
      end    
    end
    
    describe "when data was not supplied on initialization" do
      before do
        @favicon = Iconoclasm::Favicon.new(@attributes.merge({:data => nil}))
      end
      
      it "should fetch the data from the internets and return it" do
        @favicon.expects(:fetch_data).returns(@data)
        @favicon.data.should == @data
      end
      
      it "should not fetch the data from the internets on subsequent calls" do
        @favicon.expects(:fetch_data).once.returns(@data)
        @favicon.data
        @favicon.data
      end
    end
  end
  
  describe "accessing the size attribute" do
    before do
      @data = "THIS IS SOME DATA!"
      @size = 100
    end
    
    describe "when the size was supplied on initialization" do
      before do
        @favicon = Iconoclasm::Favicon.new(@attributes.merge({:data => @data, :content_length => @size}))
      end
      
      it "should return the supplied size" do
        @favicon.size.should == @size
      end
      
      it "should not check the length of the data" do
        @favicon.data.expects(:size).never
        @favicon.size
      end
    end
    
    describe "when the size was not supplied on initialization" do
      before do
        @headers.stubs(:content_length).returns(nil)
        @favicon = Iconoclasm::Favicon.new(@attributes.merge({:data => @data, :content_length => nil}))
        @favicon.instance_variable_get(:@size).should be_nil
      end
      
      it "should return the size of the data" do
        @favicon.size.should == @data.size
      end      
    end
  end
  
  describe "accessing the content type attribute" do
    before do
      @content_type = 'image/vnd.microsoft.icon'
    end
    
    describe "when the content type was supplied on initialization" do
      before do
        @favicon = Iconoclasm::Favicon.new(@attributes.merge({:content_type => @content_type}))
      end
      
      it "should return the supplied content_type" do
        @favicon.content_type.should == @content_type
      end
      
      it "should not try to check it" do
        ::MIME::Types.expects(:of).never
        @favicon.content_type
      end
    end
    
    describe "when the content type was not supplied on initialization" do
      before do
        @headers.stubs(:content_type).returns(nil)
        @favicon  = Iconoclasm::Favicon.new(@attributes.merge({:content_type => nil}))
        @mime     = mock('mime type', :content_type => @content_type)
      end
      
      it "should check the content type of the file name using the mime types library and return the first" do
        ::MIME::Types.expects(:of).with(@favicon.name).returns([@mime])
        @favicon.content_type.should == @content_type
      end
    end
  end
  
  describe "fetching the image data" do
    before do
      @favicon  = Iconoclasm::Favicon.new(@attributes)
      @response = mock('http response')
    end
    
    it "should request the icon image" do
      @favicon.expects(:get).returns(@response)
      @response.stubs(:code => 200, :body => "IMAGE DATA!")
      @favicon.fetch_data      
    end
    
    describe "when the HTTP request is successsful" do
      before do
        @favicon.stubs(:get).returns(@response)
        @data = "THIS IS ALSO TOTALLY SOME IMAGE DATA HAR HAR HAR!"
        @response.expects(:code).returns(200)
      end
      
      it "should return the content of the request (the binary image data)" do
        @response.expects(:body).returns(@data)
        @favicon.fetch_data.should == @data
      end
    end
    
    describe "when the HTTP request is not successful" do
      before do
        @favicon.stubs(:get).returns(@response)
        @response.expects(:code).returns(400)
      end
      
      it "should raise an HTTP error" do
        lambda { @favicon.fetch_data }.should raise_error(Iconoclasm::HTTPError)
      end
    end
  end
  
  describe "determining the validity of the favicon" do
    before do
      @favicon = Iconoclasm::Favicon.new(@attributes.merge({:data => "IMAGE DATA!"}))
    end
    
    describe "when the content is zero-length" do
      before do
        @favicon.stubs(:size).returns(0)
      end
      
      it "should not be valid" do
        @favicon.should_not be_valid
      end
    end
    
    describe "when the content type is a image" do
      before do
        @favicon.stubs(:content_type).returns('image/png')
      end
      
      it "should be valid" do
        @favicon.should be_valid
      end
    end
    
    describe "when the content type is HTML" do
      before do
        # This will happen when some jerkface puts a webpage where the favicon
        # should be. People on the internet are the worst.
        @favicon.stubs(:content_type).returns('text/html')
      end
      
      it "should not be valid" do
        @favicon.should_not be_valid
      end
    end
    
    describe "when the content type is nil" do
      before do
        @favicon.stubs(:content_type).returns(nil)
      end
      
      it "should not be valid" do
        @favicon.should_not be_valid
      end
    end
    
    describe "when the content type is something else" do
      before do
        @favicon.stubs(:content_type).returns('something/else')
        # eventually, maybe, I'll try harder to see if it's a valid image of some sort.
      end
      
      it "should not be valid" do
        @favicon.should_not be_valid
      end
    end
  end
  
  describe "saving the favicon" do
    before do
      @favicon = Iconoclasm::Favicon.new(@attributes.merge({:data => "IMAGE DATA!"}))
    end
    
    describe "to a tempfile" do
      before do
        @path = '/tmp/favicon.ico'
        @tempfile = stub('tempfile!', :path => @path)
      end
      
      it "should happen when there are no arguments to save" do
        @favicon.expects(:save_to_tempfile)
        @favicon.save
      end
      
      it "should dump its data to a tempfile named after the favicon" do
        Tempfile.expects(:new).with(@favicon.name).returns(@tempfile)
        @favicon.expects(:dump_data).with(@tempfile).returns(@tempfile)
        @favicon.save_to_tempfile
      end
      
      it "should set the save_path to the path to the tempfile" do
        Tempfile.stubs(:new).returns(@tempfile)
        @favicon.stubs(:dump_data).returns(@tempfile)
        @favicon.save
        @favicon.save_path.should == @path
      end
    end
    
    describe "to a file" do
      before do
        @file = stub('file')
        @path = '/var/stuff/favicons'
      end
      
      it "should happen when providing a path to save" do
        @favicon.expects(:save_to_file)
        @favicon.save(@path)
      end
      
      it "should dump its data to a file at the given path" do
        File.expects(:new).with("#{@path}/#{@favicon.name}", anything).returns(@file)
        @favicon.expects(:dump_data).with(@file)
        @favicon.save_to_file(@path)
      end
      
      it "should set the save_path to the path to the new file" do
        File.stubs(:new).returns(stub_everything)
        @favicon.save_to_file(@path)
        @favicon.save_path.should == "#{@path}/#{@favicon.name}"
      end
    end
        
    describe "to some other kind of storage" do
      before do
        @storage = Object.new
      end
      
      it "should raise an error" do
        lambda { @favicon.save(@storage) }.should raise_error(Iconoclasm::RTFMError)
      end
    end
  end
end
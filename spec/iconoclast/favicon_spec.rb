require File.expand_path(File.dirname(__FILE__) + '/../helper')

describe Iconoclast::Favicon do

  before do
    @headers    = stub('headers', :content_type => 'image/vnd.microsoft.icon', :content_length => 100)
    @name       = 'favicon.ico'
    @url        = "http://www.website.com/#{@name}"
    @attributes = {
      :url      => @url,
      :headers  => @headers
    }
  end
  
  describe "initialization" do
    before do
      @favicon = Iconoclast::Favicon.new(@attributes)
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
        @favicon = Iconoclast::Favicon.new(@attributes.merge({:data => @data}))
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
        @favicon = Iconoclast::Favicon.new(@attributes.merge({:data => nil}))
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
  
  describe "fetching the image data" do
    before do
      @favicon  = Iconoclast::Favicon.new(@attributes)
      @response = mock('http response')
    end
    
    it "should request the icon image" do
      @favicon.expects(:get).returns(@response)
      @response.stubs(:response_code => 200, :body_str => "IMAGE DATA!")
      @favicon.fetch_data      
    end
    
    describe "when the HTTP request is successsful" do
      before do
        @favicon.stubs(:get).returns(@response)
        @data = "THIS IS ALSO TOTALLY SOME IMAGE DATA HAR HAR HAR!"
        @response.expects(:response_code).returns(200)
      end
      
      it "should return the content of the request (the binary image data)" do
        @response.expects(:body_str).returns(@data)
        @favicon.fetch_data.should == @data
      end
    end
    
    describe "when the HTTP request is not successful" do
      before do
        @favicon.stubs(:get).returns(@response)
        @response.expects(:response_code).returns(400)
      end
      
      it "should raise an HTTP error" do
        lambda { @favicon.fetch_data }.should raise_error(Iconoclast::HTTPError)
      end
    end
  end
  
  describe "determining the validity of the favicon" do
    before do
      @favicon = Iconoclast::Favicon.new(@attributes.merge({:data => "IMAGE DATA!"}))
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
      @favicon = Iconoclast::Favicon.new(@attributes.merge({:data => "IMAGE DATA!"}))
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
    
    describe "to S3" do
      before do
        @klass  = stub('bucket class', :name => 'AWS::S3::Bucket')
        @link   = "http://s3.amazonaws.com/bucketfulloffavicons"
        @bucket = stub('bucket', :class => @klass, :public_link => @link, :put => true)
      end
      
      it "should happen when providing a bucket to save" do
        @favicon.expects(:save_to_s3)
        @favicon.save(@bucket)
      end
      
      it "should put the icon data in the bucket keyed to the icon's name" do
        @bucket.expects(:put).with(@favicon.name, @favicon.data).returns(true)
        @favicon.save_to_s3(@bucket)
      end
      
      it "should set the save_path to the url to the resource" do
        @favicon.save_to_s3(@bucket)
        @favicon.save_path.should == "#{@bucket.public_link}/#{@favicon.name}"
      end
      
      describe "when there's an error writing to the bucket" do
        before do
          @bucket.stubs(:put).returns(false)
        end
        
        it "should raise an error" do
          lambda { @favicon.save_to_s3(@bucket) }.should raise_error(Iconoclast::S3Error)
        end
      end
    end
    
    describe "to some other kind of storage" do
      before do
        @storage = Object.new
      end
      
      it "should raise an error" do
        lambda { @favicon.save(@storage) }.should raise_error(Iconoclast::RTFMError)
      end
    end
  end
end
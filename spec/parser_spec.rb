require 'spec_helper'

describe Parser do
  before :all do
    @parser = Parser.new("config.txt")
  end

  describe "initialize" do
    it "reads the config file" do
      @parser.original_string.should eql(File.read("config.txt"))
    end

    it "has a data attribute" do
      @parser.data.should be_a(Hash)
    end
  end

  describe "#header?" do
    it "recognizes a standard header" do
      string = "[header]\n"
      @parser.header?(string).should be(true)
    end

    it "recognizes a header with surrounding spaces" do
      string = "[ header ]\n"
      @parser.header?(string).should be(true)
    end

    it "recognizes a header with spaces in name" do
      string = "[meta data]\n"
      @parser.header?(string).should be(true)
    end

    it "does not recognize a header with a space in column1" do
      string = " [header]\n"
      @parser.header?(string).should_not be(true)
    end

    it "does not recognize a key:value as a header" do
      string = "key:value\n"
      @parser.header?(string).should_not be(true)
    end
  end

  describe "#extract_header" do
    it "returns header from a standard header" do
      string = "[header]\n"
      @parser.extract_header(string).should eql("header")
    end

    it "returns header from a header with spaces" do
      string = "[ header ]\n"
      @parser.extract_header(string).should eql("header")
    end
  end

  describe "#key_value?" do
    it "recognizes a standard key value" do
      string = "key:value\n"
      @parser.key_value?(string).should be(true)
    end

    it "recognizes a key value with spaces around colon" do
      string = "key :  value \n"
      @parser.key_value?(string).should be(true)
    end

    it "does not recognize a key value with a space in column 1" do
      string = " key:value\n"
      @parser.key_value?(string).should be(false)
    end
  end

  describe "#extract_key_value" do
    it "returns a hash" do
      string = "key:value\n"
      @parser.extract_key_value(string).should be_a(Hash)
    end

    it "returns a key value from a standard key value" do
      string = "key:value\n"
      @parser.extract_key_value(string).should eql({'key' => 'value'})
    end
  end

  describe "#headers" do
    it "returns an array of headers" do
      array = ["header", "meta data", "trailer"]
      @parser.headers.should =~ array
    end
  end

  describe "create_data" do
    before :each do
      @parser = Parser.new("config.txt")
    end
    it "contains headers" do
      headers = ["header1", "header2"]
      string = "[header1]\n[header2]\n"
      @parser.create_data(string)
      @parser.data.keys.should =~ headers
    end

    it "contains a section with header and key value" do
      string = "[header1 ]\napple: red\n"
      @parser.create_data(string)
      @parser.data.should eql( {'header1' => {'apple' => 'red'}} )
    end
  end

end
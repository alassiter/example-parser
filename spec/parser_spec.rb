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
    it "is true with proper key value" do
      string = "key:value\n"
      @parser.key_value?(string).should be(true)
    end

    it "is true with key value with spaces around colon" do
      string = "key :  value \n"
      @parser.key_value?(string).should be(true)
    end

    it "is true with a key of multiple words" do
      string = "key word: value\n"
      @parser.key_value?(string).should be(true)
    end

    it "is false with key value with a space in column 1" do
      string = " key:value\n"
      @parser.key_value?(string).should be(false)
    end

    it "is false with no colon" do
      string = " key value"
      @parser.key_value?(string).should be(false)
    end

    it "is false with only a colon" do
      string = " :"
      @parser.key_value?(string).should be(false)
    end
  end

  describe "#value_remainder?" do
    it "is true with one whitespace followed by string" do
      string = " remaining value string"
      @parser.value_remainder?(string).should be(true)
    end

    it "is true with multiple whitespaces followed by string" do
      string = "    remaining value string"
      @parser.value_remainder?(string).should be(true)
    end

    it "is false with no whitespaces" do
      string = "improperly formated line"
      @parser.value_remainder?(string).should be(false)
    end

    it "is false with only whitespaces" do
      string = "          "
      @parser.value_remainder?(string).should be(false)
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

  describe "#extract_value_remainder" do
    it "returns string from a value_remainder line" do
      string = "  remaining value string"
      @parser.extract_value_remainder(string).should eql("remaining value string")
    end
  end

  describe "#set_value_type" do
    it "returns a float" do
      string = "10.4"
      @parser.set_value_type(string).should be_a(Float)
    end

    it "returns an integer" do
      string = "10"
      @parser.set_value_type(string).should be_a(Integer)
    end

    it "defaults to string" do
      string = "Not the number 10"
      @parser.set_value_type(string).should be_a(String)
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

    it "contains default data" do
      @parser.create_data
      @parser.data.should_not be_empty
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

    it "adds value remainders to preceding value" do
      string = "[header1 ]\napple: red apples are\n the best"
      @parser.create_data(string)
      @parser.data.should eql( {'header1' => {'apple' => 'red apples are the best'}})
    end

    it "properly changes the type of value" do
      string = "[movie]\ntitle:A Red Furnace\nprice:10.4\nqty:5"
      @parser.create_data(string)
      @parser.data.should eql( {'movie' => {'title' => 'A Red Furnace', 'price' => 10.4, 'qty' => 5}} )
    end
  end

end
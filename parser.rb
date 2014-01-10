class Parser
  attr_reader :original_string
  attr_accessor :data

  def initialize(file)
    @original_string = File.read(file)
    @data = {}
  end

  def headers
    headers = []
    @original_string.each_line do |line|
      if header?(line)
        headers << extract_header(line)
      end
    end
    headers
  end

  def create_data(string)
    current_header = ''
    string.each_line do |line|
      if header?(line)
        current_header = extract_header(line)
        @data[current_header] = {}
      elsif key_value?(line)
        current_key_value = extract_key_value(line)
        @data[current_header][current_key_value.keys.first] = current_key_value.values.first
      end
    end
    @data
  end

  def header?(string)
    !!(string =~ header_match)
  end

  def key_value?(string)
    !!(string =~ key_value_match)
  end

  def extract_header(string)
    string.match(header_match)[1]
  end

  def extract_key_value(string)
    key_value_array = string.split(":").map!{|e| e.strip}
    Hash[*key_value_array]
  end

  private
  def header_match
    /^\[\W*([a-zA-Z0-9 ]+\b)\W*\]/
    # /^\[\W*(.+)\W*\]/
  end

  def key_value_match
    /^\w+\s*:\s*\w+\s*/
  end

end
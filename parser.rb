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

  def create_data(string = original_string)
    current_header = ''
    current_key = ''
    string.each_line do |line|
      case
      when header?(line)
        current_header = extract_header(line)
        @data[current_header] = {}
      when key_value?(line)
        current_key_value = extract_key_value(line)
        current_key = current_key_value.keys.first
        @data[current_header][current_key] = process_value_type(current_key_value.values.first)
      when value_remainder?(line)
        value_string = extract_value_remainder(line)
        @data[current_header][current_key] << " #{value_string}"
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

  def value_remainder?(string)
    !!(string =~ remainder_match)
  end

  def extract_header(string)
    string.match(header_match)[1]
  end

  def extract_key_value(string)
    key_value_array = string.split(":").map!{|e| e.strip}
    Hash[*key_value_array]
  end

  def process_value_type(value)
    case
    when value.to_f.to_s == value
      value.to_f
    when value.to_i.to_s == value
      value.to_i
    else
      value
    end
  end

  def extract_value_remainder(string)
    string.match(remainder_match)[1]
  end

  private
  def header_match
    /^\[\W*([a-zA-Z0-9 ]+\b)\W*\]/
    # /^\[\W*(.+)\W*\]/
  end

  def key_value_match
    /^\S.*:\s*\w+\s*/
  end

  def remainder_match
    /^\s+(\S.*)/
  end

end
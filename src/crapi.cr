require "http/server"
require "option_parser"
require "mime"
require "yaml"
require "json"

VERSION = "0.1.0"

MIME.register(".yml", "text/x-yaml")
MIME.register(".yaml", "text/x-yaml")

alias AnyDataType = JSON::Any | YAML::Any

class Options
  property :port, :file_path

  def initialize(@port = 3000_u16, @file_path = "data.yml"); end

  def self.parse
    options = new

    OptionParser.parse do |parser|
      parser.banner = "Crapi #{VERSION}\n"
      parser.separator("Usage:")
      parser.separator("    crapi [OPTIONS] [FILE]")

      parser.separator("Options:")

      parser.on "-v", "--version", "Show version" do
        puts "version #{VERSION}"
        exit
      end

      parser.on "-h", "--help", "Show help" do
        puts parser
        exit
      end

      parser.on "-p PORT", "--port=PORT", "Set the port (defaults to #{options.port})" do |port|
        options.port = UInt16.new(port)
      end

      parser.on "-f FILE_PATH", "--file=FILE_PATH", "Set the file path (defaults to #{options.file_path})" do |file_path|
        options.file_path = file_path
      end

      parser.missing_option do |option_flag|
        STDERR.puts "ERROR: #{option_flag} is missing something.\n\n"
        STDERR.puts parser
        exit(1)
      end

      parser.invalid_option do |option_flag|
        STDERR.puts "ERROR: #{option_flag} is not a valid option.\n\n"
        STDERR.puts parser
        exit(2)
      end
    end
    options
  end
end

def ensure_file_readable(path : String)
  return if File.readable?(path)

  STDERR.puts "ERROR: File at `#{path}` is not readable."
  exit(10)
end

def parse_file(path : String)
  ensure_file_readable(path)

  case MIME.from_filename?(path)
  when "text/x-yaml"
    YAML.parse(File.read(path))
  when "application/json"
    JSON.parse(File.read(path))
  else
    STDERR.puts "ERROR: File at `#{path}` is neither YAML nor JSON."
    exit(11)
  end
rescue e: JSON::ParseException | YAML::ParseException
  STDERR.puts "ERROR: File at `#{path}` is invalid: #{e.message}"
  exit(20)
end

# Because dig? doesn't work for us and I'm stupid
def dig_data?(data : AnyDataType, keys : Array(String))
  keys.reduce(data) do |acc, key|
    return unless acc.raw.is_a?(Hash)
    return unless acc[key]?

    acc[key]
  end
end

def path_to_lookup_keys(path : String)
  path.split("/")
    .reject(&.blank?)
    .map { |item| item.is_a?(String) ? item : String.new(item) }
end


def serve(data : AnyDataType, options : Options)
  server = HTTP::Server.new do |context|
    keys = path_to_lookup_keys(context.request.path)
    value = dig_data?(data, keys)

    if (value)
      context.response.content_type = "application/json"
      context.response.print(%({"data":#{value.to_json}}))
    else
      context.response.respond_with_status(404)
      end
  end

  address = server.bind_tcp(options.port)

  puts "Crapi is listening on port #{options.port}!"

  server.listen
end

def main
  options = Options.parse
  data = parse_file(options.file_path)

  serve(data, options)
end

main

require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'
require 'multi_json'
require '../lib/datasift'

def parse(args)
  options          = OpenStruct.new
  options.auth     = nil
  options.endpoint = nil
  options.command  = 'core'
  options.params   = {}
  options.api      = 'api.datasift.com'

  opt_parser = OptionParser.new do |opts|
    opts.banner = 'Usage: cli.rb [-c] [--api] -a -e [-p*]'
    opts.separator 'Specific options:'

    opts.on('-a', '--auth AUTH', 'DataSift username:api_key') do |username|
      api_key = ARGV.length>0 && ARGV[0].index('-') == 0 ? '' : ARGV[0]
      if username == nil || api_key == nil || username.empty? || api_key.empty?
        puts 'Unable to parse username and API key, they must be in the format username api_key'
        puts Cli.parse(%w(-h))
        exit
      end
      options.auth = {:username => username, :api_key => api_key}
    end

    opts.on('-e', '--endpoint ENDPOINT', 'Defaults to core, must be one of core,push,historics,preview,sources') do |e|
      options.endpoint = e
    end

    opts.on('-c', '--command COMMAND', 'DataSift endpoint, depends on the endpoint') do |e|
      options.command = e|| 'core'
    end

    opts.on('-p', '--param PARAM', 'Command specific parameters e.g. -p name value') do |k|
      # value is ARGV[0] unless ARGV[0] starts with a hyphen
      options.params[k] = ARGV.length>0 && ARGV[0].index('-') == 0 ? '' : ARGV[0]
    end

    opts.on('--api', 'Override the API URL') do |e|
      options.api = e
    end

    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end

    opts.on_tail('--version', 'Show version') do
      puts :: DataSift::VERSION
      exit
    end
  end

  opt_parser.parse!(args)
  options #.marshal_dump
end

# parse()

def run_core_command (c, command, p)
  case command
    when 'compile'
      c.compile(p['csdl'])
    else
      puts 'Unknown command for the core endpoint'
      exit
  end
end

def to_output(r)
  MultiJson.dump({
                     :status  => r[:http][:status],
                     :headers => r[:http][:headers],
                     :body    => r[:data]
                 }, :pretty => true)
end

begin
  options = parse(ARGV)
  req     = [:auth, :endpoint]
  missing = req.select { |param| options.send(param).nil? }
  unless missing.empty?
    puts "The following options are required : #{missing.join(', ')}"
    puts parse(%w(-h))
    exit
  end
  config =
      {
          :username => options.auth[:username],
          :api_key  => options.auth[:api_key],
          :api_host => options.api
      }
  datasift = DataSift::Client.new(config)

  #obj = options.endpoint == 'core' ? datasift : datasift.send(options.endpoint.to_sym)
  #puts obj.send(options.command, *options.params)
  res      = case options.endpoint
               when 'core'
                 run_core_command(datasift, options.command, options.params)
               else
                 puts 'Unsupported/Unknown endpoint'
                 exit
             end
  puts to_output(res)
rescue DataSiftError => e
  puts e.message
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts parse(%w(-h))
  exit
end
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

class Cli

  COMMANDS = {
      :core      => [
          :compile,
          :validate,
          :usage,
          :balance,
          :dpu,
          :pull,
      ],
      :push      => [
          :validate,
          :create,
          :update,
          :delete,
          :pause,
          :resume,
          :stop,
          :log,
          :get,
      ],
      :preview   => [
          :create,
          :get,
      ],
      :sources   => [
          :create,
          :update,
          :delete,
          :start,
          :stop,
          :log,
          :get,
      ],
      :historics => [
          :prepare,
          :update,
          :delete,
          :start,
          :stop,
          :status,
          :get,
      ],
  }

  def self.parse(args)
    options          = OpenStruct.new
    options.auth     = nil
    options.endpoint = nil
    options.command  = 'core'
    options.params   = {}
    options.api      = 'api.datasift.com'

    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: cli.rb [-c] [--api] -a -e [-p*]'
      opts.separator 'Specific options:'

      opts.on('-a', '--auth AUTH', 'DataSift username:api_key') do |auth|
        (username, api_key) = auth.split(':')
        if username == nil || api_key == nil
          puts 'Unable to parse username and API key, they must be in the format username:api_key'
          puts Cli.parse(%w(-h))
          exit
        end
        options.auth = {:username => username, :api_key => api_key}
      end

      opts.on('-e', '--endpoint ENDPOINT', 'DataSift endpoint, depends on the command') do |e|
        options.endpoint = e
      end

      opts.on('-c', '--command COMMAND', 'Defaults to core, must be one of ' + COMMANDS.keys.join(',')) do |e|
        options.command = e|| 'core'
      end

      opts.on('-p', '--param PARAM', 'Command specific parameters e.g. -p name value') do |k|
        # value is ARGV[0] unless ARGV[0] starts with a hyphen
        options.params[k] = ARGV[0].index('-') == 0 ? '' : ARGV[0]
      end

      opts.on('--api', 'Override the API URL') do |e|
        options.api = e
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end

      opts.on_tail('--version', 'Show version') do
        puts ::Version.join('.')
        exit
      end
    end

    opt_parser.parse!(args)
    options.marshal_dump
  end # parse()

end

#options = Cli.parse(ARGV)
#pp options

begin
  #pp ARGV
  options = Cli.parse(ARGV)
  req     = [:auth, :endpoint]
  missing = req.select { |param| options[param].nil? }
  if not missing.empty?
    puts "The following options are required : #{missing.join(', ')}"
    puts Cli.parse(%w(-h))
    exit
  end
  pp options
  config   =
      {
          :username => options.auth[:username],
          :api_key  => options.auth[:api_key],
          :api_host => options.api
      }
  datasift = DataSift::Client.new(config)
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts Cli.parse(%w(-h))
  exit
end

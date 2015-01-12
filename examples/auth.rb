class DataSiftExample
  require 'datasift'

  def initialize
    @username = 'dtsn'
    @api_key  = 'af10bf9030e93bba28af1fec1cf76d9d'
    @config   = {:username => @username, :api_key => @api_key, :enable_ssl => false, :api_host => 'api.fido.daniel2.devms.net'}
    @params   = {
      :output_type => 's3',
      :output_params => {
        :bucket             => 'YOUR_BUCKET_NAME',
        :directory          => 'ruby',
        :acl                => 'private',
        :delivery_frequency => 0,
        :max_size           => 104857600,
        :file_prefix        => 'DataSift',
        :auth => {
          :access_key => 'ADD_YOUR_ACCESS_KEY',
          :secret_key => 'ADD_YOUR_SECRET_KEY',
        }
      }
    }
    @pull_params = {
      :output_type => 'pull',
      :output_params => {
        :max_size => 52428800
      }
    }
    @datasift = DataSift::Client.new(@config)
  end

  attr_reader :datasift

  def create_push(hash, is_historics_id = false)
    create_params = @params.merge ({
        #hash or historics_id can be used but not both
        :name           => 'My awesome push subscription',
        :initial_status => 'active', # or 'paused' or 'waiting_for_start'
    })
    if is_historics_id
      create_params.merge!({:historics_id => hash})
    else
      create_params.merge!({:hash  => hash,
                            #start and end are not valid for historics
                            :start => Time.now.to_i,
                            :end   => Time.now.to_i + 320
                           })
    end
    puts 'Creating subscription'
    subscription = @datasift.push.create create_params
    puts 'Create push => ' + subscription.to_s
    subscription
  end
end

class DataSiftExample
  require 'datasift'

  def initialize
    #only SSLv3 and TLSv1 currently supported, TLSv1 preferred
    # this is fixed in REST client and is scheduled for the 1.7.0 release
    # see https://github.com/rest-client/rest-client/pull/123
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'TLSv1'
    @username = 'DATASIFT_USERNAME'
    @api_key  = 'DATASIFT_API_KEY'
    @config   = {:username => @username, :api_key => @api_key, :enable_ssl => true}
    @params   = {
        :output_type                       => 's3',
        'output_params.bucket'             => 'YOUR_BUCKET_NAME',
        'output_params.directory'          => 'ruby',
        'output_params.acl'                => 'private',
        'output_params.auth.access_key'    => 'ADD_YOUR_ACCESS_KEY',
        'output_params.auth.secret_key'    => 'ADD_YOUR_SECRET_KEY',
        'output_params.delivery_frequency' => 0,
        'output_params.max_size'           => 104857600,
        'output_params.file_prefix'        => 'DataSift',
    }
    @pull_params = {
      :output_type => 'pull',
      'output_params.max_size' => 52428800
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

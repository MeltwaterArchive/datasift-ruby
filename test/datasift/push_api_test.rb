require File.expand_path('../../test_helper', __FILE__)

describe 'DataSift::Push' do

  before do
    auth      = DataSiftExample.new
    @datasift = auth.datasift
    @data     = OpenStruct.new
    @statuses = OpenStruct.new

    @statuses.valid        = 200
    @statuses.no_content   = 204
#    @statuses.invalid_csdl = 400
#    @statuses.bad_request  = 400

    @data.params = {
        'name'                              => 'connectorhttp',
        'output_type'                       => 'http',
        'output_params.url'                 => 'http://example.com/datasift',
        'output_params.compression'         => 'none',
        'output_params.delivery_frequency'  => '0',
        'output_params.max_size'            => '10485760',
        'output_params.verify_ssl'          => 'false',
        'output_params.auth.type'           => 'basic',
        'output_params.auth.username'       => 'username',
        'output_params.auth.password'       => 'password'
      }

    @data.subscription_params  = {:id           => '7802b84cfe79e50e0a6e3cdac5ce54ab',
                                  :stream_hash  => '145ea24a4d83a14ecb9077b831f14809',
                                  :historics_id => '5f569d6f99002bfaa483' }
  end

  describe '#push/validate' do
    before do
      #valid /push/validate request
      stub_request(:post, "https://api.datasift.com/v1/push/validate").
      with(:body => @data.params).
      to_return(status: @statuses.valid,
                body:   fixture('push_validate_valid.json'))
    end

    it 'can validate a push destination' do
      @datasift.push.valid? @data.params
      assert_requested(:post, 'https://api.datasift.com/v1/push/validate', :body => @data.params)
    end
  end

  describe '#push/create' do
    before do
      @data.params.merge({'hash' => '145ea24a4d83a14ecb9077b831f14809'})

      #valid /push/create request
      stub_request(:post, "https://api.datasift.com/v1/push/create").
      with(:body => @data.params).
      to_return(status: @statuses.valid,
                body:   fixture('push_create_valid.json'))
    end

    it 'can create a push subscription' do
      @datasift.push.create @data.params
      assert_requested(:post, 'https://api.datasift.com/v1/push/create', :body => @data.params)
    end
  end

  describe '#push/get' do
    before do
      @data.list_params = { :order_by   => 'created_at',
                            :order_dir  => 'desc',
                            :page       => 1,
                            :per_page   => 20 }

      #valid /push/get request
      stub_request(:get, "https://api.datasift.com/v1/push/get").
        with(:query => {:id => @data.subscription_params['id']}).
        to_return(status: @statuses.valid,
                  body:   fixture('push_get_valid.json'))

      #valid /push/get list request
      stub_request(:get, "https://api.datasift.com/v1/push/get").
        with(:query => @data.list_params).
        to_return(status:  @statuses.valid,
                  body:    fixture('push_get_list_valid.json'))

      #valid /push/get list by hash request
      stub_request(:get, "https://api.datasift.com/v1/push/get").
        with(:query => @data.list_params.merge('hash' => @data.subscription_params['stream_hash'])).
        to_return(status:  @statuses.valid,
                  body:    fixture('push_get_list_by_hash_valid.json'))

      #valid /push/get list by historics id request
      stub_request(:get, "https://api.datasift.com/v1/push/get").
        with(:query => @data.list_params.merge('historics_id' => @data.subscription_params['historics_id'])).
        to_return(status:  @statuses.valid,
                  body:    fixture('push_get_list_by_historics_id_valid.json'))
    end

    it 'can get a specific push subscription' do
      @datasift.push.get_by_subscription @data.subscription_params['id']
      assert_requested(:get, 'https://api.datasift.com/v1/push/get', :query => {:id => @data.subscription_params['id']})
    end

    it 'can get a list of push subscriptions' do
      @datasift.push.get
      assert_requested(:get, 'https://api.datasift.com/v1/push/get', :query => @data.list_params)
    end

    it 'can get a list of push subscriptions by stream hash' do
      @datasift.push.get_by_hash @data.subscription_params['stream_hash']
      assert_requested(:get, 'https://api.datasift.com/v1/push/get', :query => @data.list_params.merge('hash' => @data.subscription_params['stream_hash']))
    end

    it 'can get a list of push subscriptions by historic id' do
      @datasift.push.get_by_historics_id @data.subscription_params['historics_id']
      assert_requested(:get, 'https://api.datasift.com/v1/push/get', :query => @data.list_params.merge('historics_id' => @data.subscription_params['historics_id']))
    end
  end

  describe '#push/stop' do
    before do
      #valid /push/stop request
      stub_request(:put, "https://api.datasift.com/v1/push/stop").
        with(:body => {:id => @data.subscription_params[:id]}).
        to_return(status: @statuses.valid,
                  body:   fixture('push_stop_valid.json'))
    end

    it 'can stop a push subscription' do
      @datasift.push.stop @data.subscription_params[:id]
      assert_requested(:put, 'https://api.datasift.com/v1/push/stop', :body => {:id => @data.subscription_params[:id]})
    end
  end

  describe '#push/log' do
    before do
      @data.list_params = { :order_by   => 'request_time',
                            :order_dir  => 'desc',
                            :page       => 1,
                            :per_page   => 20 }

      #valid /push/log request
      stub_request(:get, "https://api.datasift.com/v1/push/log").
        with(:query => @data.list_params.merge('id' => @data.subscription_params[:id])).
        to_return(status: @statuses.valid,
                  body:   fixture('push_log_valid.json'))
      #valid /push/log list request
      stub_request(:get, "https://api.datasift.com/v1/push/log").
        with(:query => @data.list_params).
        to_return(status: @statuses.valid,
                  body:   fixture('push_log_valid.json'))
    end

    it 'can get the /push/log for a given subscription' do
      @datasift.push.log_for @data.subscription_params[:id]
      assert_requested(:get, 'https://api.datasift.com/v1/push/log', :query => @data.list_params.merge('id' => @data.subscription_params[:id]))
    end

    it 'can get the /push/log for all subscriptions' do
      @datasift.push.log
      assert_requested(:get, 'https://api.datasift.com/v1/push/log', :query => @data.list_params)
    end
  end

  describe '#push/pause' do
    before do
      #valid /push/pause request
      stub_request(:put, "https://api.datasift.com/v1/push/pause").
        with(:body => {:id => @data.subscription_params[:id]}).
        to_return(status: @statuses.valid,
                  body:   fixture('push_pause_valid.json'))
    end

    it 'can pause a push subscription' do
      @datasift.push.pause @data.subscription_params[:id]
      assert_requested(:put, 'https://api.datasift.com/v1/push/pause', :body => {:id => @data.subscription_params[:id]})
    end
  end

  describe '#push/resume' do
    before do
      #valid /push/resume request
      stub_request(:put, "https://api.datasift.com/v1/push/resume").
        with(:body => {:id => @data.subscription_params[:id]}).
        to_return(status: @statuses.valid,
                  body:   fixture('push_get_valid.json'))
    end

    it 'can resume a push subscription' do
      @datasift.push.resume @data.subscription_params[:id]
      assert_requested(:put, 'https://api.datasift.com/v1/push/resume', :body => {:id => @data.subscription_params[:id]})
    end
  end

  describe '#push/update' do
    before do
      @data.update_params = {id: @data.subscription_params[:id]}
      #valid /push/update request
      stub_request(:post, "https://api.datasift.com/v1/push/update").
        with(:body => {:id => @data.subscription_params[:id]}).
        to_return(status: @statuses.valid,
                  body:   fixture('push_get_valid.json'))
    end

    it 'can update a push subscription' do
      @datasift.push.update @data.update_params
      assert_requested(:post, 'https://api.datasift.com/v1/push/update', :body => @data.update_params)
    end
  end

  describe '#push/delete' do
    before do
      #valid /push/delete request
      stub_request(:delete, "https://api.datasift.com/v1/push/delete").
        with(:query => {:id => @data.subscription_params[:id]}).
        to_return(status: @statuses.no_content)
    end

    it 'can delete a push subscription' do
      @datasift.push.delete @data.subscription_params[:id]
      assert_requested(:delete, 'https://api.datasift.com/v1/push/delete', :query => {:id => @data.subscription_params[:id]})
    end
  end
end

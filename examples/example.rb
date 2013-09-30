class Example
  @username = 'zcourts'
  @api_key  ='44067e0ff342b76b52b36a63eea8e21a'
  @config   ={:username => @username, :api_key => @api_key}
  require '../lib/datasift'
  datasift = DataSift::Client.new(@config)
  begin
    #csdl = 'interaction.content contains "test"'
    #puts datasift.valid? csdl
    #stream= datasift.compile csdl
    #puts stream[:data][:hash]
    #puts datasift.dpu stream[:data][:hash]
    #puts datasift.balance
    #puts datasift.usage

    datasift.stream.on_delete = lambda { |m| puts m }

    datasift.stream.on_error = lambda do |e|
      puts e.message
    end

    datasift.stream.subscribe '13e9347e7da32f19fcdb08e297019d2e'
      #rescue DataSiftError
  rescue DataSiftError => dse
    puts dse.message
    # Then match specific one to take action - All errors thrown by the client extend DataSiftError
    case dse
      when ConnectionError
        # some connection error
      when AuthError
      when BadRequestError
      else
        # do something else...
    end
  end
end
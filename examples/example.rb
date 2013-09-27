class Example
  @username = 'zcourts'
  @api_key  ='44067e0ff342b76b52b36a63eea8e21a'
  @config   ={:username => @username, :api_key => @api_key}
  require '../lib/datasift'
  datasift = DataSift::Client.new(@config)
  begin
    csdl = 'interaction.content contains "test"'
    puts datasift.valid? csdl
    stream= datasift.compile csdl
    puts stream[:data][:hash]
    puts datasift.dpu stream[:data][:hash]
    puts datasift.balance
    puts datasift.usage
      #rescue DataSiftError
  rescue DataSiftError => dse
    puts 'Error ==> ' + dse.message
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

  # WS support via WM???
  EM.run do
    ws_url = "ws://websocket.datasift.com/multi?username=#{@config[:username]}&api_key=#{@config[:api_key]}"
    puts ws_url
    ws = WebSocket::EventMachine::Client.connect(:uri => ws_url)

    ws.onopen do
      puts "Connected"
    end

    ws.onmessage do |msg, type|
      puts "Received message: #{msg}"
    end

    ws.onclose do
      puts "Disconnected"
    end

    ws.send "Hello Server!"
  end
end
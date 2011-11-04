#
# stream_consumer_http.rb - This file contains the StreamConsumer_HTTP class.
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# The StreamConsumer_HTTP class implements HTTP streaming.

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')

require 'uri'
require 'socket'
require 'yajl'

module DataSift

	class StreamConsumer_HTTP < StreamConsumer

		# Constructor. Requires valid user and definition objects.
		def initialize(user, definition)
			super
		end

		def onStart(&block)
			begin
				reconnect() unless !@socket.nil? and !@socket.closed?

				parser = Yajl::Parser.new
				parser.on_parse_complete = block if block_given?
				if @response_head[:headers]["Transfer-Encoding"] == 'chunked'
					if block_given?
						chunkLeft = 0
						while !@socket.eof? && (line = @socket.gets)
							break if line.match /^0.*?\r\n/
							next if line == "\r\n"
							size = line.hex
							json = @socket.read(size)
							next if json.nil?
							chunkLeft = size-json.size
							if chunkLeft == 0
								if json.length > 100
									parser << json
								end
							else
								# received only part of the chunk, grab the rest
								parser << @socket.read(chunkLeft)
							end
						end
					else
						raise StreamError, 'Chunked responses detected, but no block given to handle the chunks.'
					end
				else
					content_type = @response_head[:headers]['Content-Type'].split(';')
					content_type = content_type.first
					if ALLOWED_MIME_TYPES.include?(content_type)
						case @response_head[:headers]['Content-Encoding']
						when 'gzip'
							return Yajl::Gzip::StreamReader.parse(@socket, opts, &block)
						when 'deflate'
							return Yajl::Deflate::StreamReader.parse(@socket, opts.merge({:deflate_options => -Zlib::MAX_WBITS}), &block)
						when 'bzip2'
							return Yajl::Bzip2::StreamReader.parse(@socket, opts, &block)
						else
							return parser.parse(@socket)
						end
					else
						raise StreamError, 'Unhandled response MIME type ' + content_type
					end
				end
			end while @auto_reconnect and @state == StreamConsumer::STATE_RUNNING

			disconnect()

			if @state == StreamConsumer::STATE_STOPPING
				@stop_reason = 'Stop requested'
			else
				@stop_reason = 'Connection dropped'
			end

			onStop(@stop_reason)
		end

		def reconnect()
			uri = URI.parse('http://' + User::STREAM_BASE_URL + @definition.hash +
											'?username=' + CGI.escape(@user.username) + '&api_key=' + CGI.escape(@user.api_key))

			user_agent = @user.getUserAgent()

			request = "GET #{uri.path}#{uri.query ? "?"+uri.query : nil} HTTP/1.1\r\n"
			request << "Host: #{uri.host}\r\n"
			request << "User-Agent: #{user_agent}\r\n"
			request << "Accept: */*\r\n"
			request << "\r\n"

			connection_delay = 0

			begin
				# Close the socket if it's open
				disconnect()

				# Back off a bit if required
				sleep(connection_delay) if connection_delay > 0

				begin
					@socket = TCPSocket.new(uri.host, uri.port)

					@socket.write(request)
					@response_head = {}
					@response_head[:headers] = {}

					# Read the headers
					@socket.each_line do |line|
						if line == "\r\n" # end of the headers
							break
						else
							header = line.split(": ")
							if header.size == 1
								header = header[0].split(" ")
								@response_head[:version] = header[0]
								@response_head[:code] = header[1].to_i
								@response_head[:msg] = header[2]
							else
								@response_head[:headers][header[0]] = header[1].strip
							end
						end
					end

					if @response_head[:code] == 200
						# Success!
						@state = StreamConsumer::STATE_RUNNING
					elsif @response_head[:code] == 404
						raise StreamError, 'Hash not found!'
					else
						puts 'Connection failed: ' + @response_head[:code] + ' ' + @response_head[:msg]
						if connection_delay == 0
							connection_delay = 10;
						elsif connection_delay < 240
							connection_delay *= 2;
						else
							raise StreamError, 'Connection failed: ' + @response_head[:code] + ' ' + @response_head[:msg]
						end
					end
				#rescue
				#	if connection_delay == 0
				#		connection_delay = 1
				#	elsif connection_delay <= 16
				#		connection_delay += 1
				#	else
				#		raise StreamError, 'Connection failed due to a network error'
				#	end
				end
			end while @state != StreamConsumer::STATE_RUNNING
		end

		def disconnect()
			@socket.close if !@socket.nil? and !@socket.closed?
		end

	end

end

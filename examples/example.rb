class Example
  @username = 'zcourts'
  @api_key='44067e0ff342b76b52b36a63eea8e21a'

  require '../lib/datasift'
  datasift = DataSift::Client.new(@username, @api_key)

  puts datasift.core.valid? 'interaction.content contains "test"'
end
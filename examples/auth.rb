class DataSiftExample
  require '../lib/datasift'

  def initialize
    @username = 'zcourts'
    @api_key  ='44067e0ff342b76b52b36a63eea8e21a'
    @config   ={:username => @username, :api_key => @api_key}
  end
end
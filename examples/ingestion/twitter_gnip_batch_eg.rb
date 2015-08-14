require './../auth'
class TwitterGnipBatchEg < DataSiftExample
  def initialize
    super
    @datasift = DataSift::Client.new(@config)
    run
  end

  def run
    begin
      # "gnip_1" is the default mapping used to map Tweets ingested from Gnip into a
      #   format DataSift can use. Using this mapping will altomatically define the
      #   IDML you need to use for this source
      resource = [{
        parameters: {
          mapping: "gnip_1"
        }
      }]
      puts "Creating Managed Source for ODP Ingestion\n"
      source = @datasift.managed_source.create('twitter_gnip', 'Ruby ODP API', {}, resource)
      puts "Manage Source with ID #{source[:data][:id]} created"

      lines = 0
      payload = ''
      # Read interactions out of the fake Tweets fixture file
      File.readlines('./../../test/fixtures/data/fake_gnip_tweets.json').each do |line|
        lines += 1
        payload += line

        # Upload interactions as batches of five
        if lines % 5 == 0
          puts "\nUploading a batch of five interactions\n"
          puts @datasift.odp.ingest(source[:data][:id], payload)[:data].to_json
          payload = ''
        end
      end

      puts "\nCleanup after this test and delete the Managed Source"
      @datasift.managed_source.delete(source[:data][:id])

    rescue DataSiftError => dse
      puts dse.message
      # Then match specific one to take action - All errors thrown by the client extend
      #   DataSiftError
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
end

TwitterGnipBatchEg.new

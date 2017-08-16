##
# This script runs through PYLON Reference API examples using v1.5 of the API
##

require './../auth'
class ReferenceApi < DataSiftExample
  def initialize
    super
    run_references
  end

  def run_references
    begin

      @pylon_config = @config.dup
      @pylon_config.merge!(
        api_version: 'v1.5'
      )
      @datasift = DataSift::Client.new(@pylon_config)

      puts "List all reference data sets available for this service:"
      @datasift.pylon.reference(service: 'linkedin')[:data][:data].each do |reference_data|
        puts "#{reference_data[:slug]} - #{reference_data[:name]}"
      end

      puts "\nTake a closer look at the company_sizes reference data:"
      puts @datasift.pylon.reference(service: 'linkedin', slug: 'company_sizes')[:data][:values]

      rescue DataSiftError => dse
        puts dse.inspect
    end
  end
end

ReferenceApi.new

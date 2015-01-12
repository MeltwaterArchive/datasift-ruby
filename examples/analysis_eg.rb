require './auth'
class AnalysisApi < DataSiftExample
  def initialize
    super
    run_analysis
  end

  def run_analysis
    begin
      csdl = '(fb.content any "coffee" OR fb.hashtags in "coffee") AND fb.language in "en"'

      puts "Check this CSDL is valid: #{csdl}"
      puts @datasift.analysis.valid?(csdl, false)

      puts "\nCompile my CSDL"
      compiled = @datasift.analysis.compile csdl
      hash = compiled[:data][:hash]
      puts "Hash: #{hash}"

      puts "\nStart recording filter with hash #{hash}"
      filter = @datasift.analysis.start(hash, 'Facebook Pylon Test Filter')
      puts filter

      puts "\nSleep for 10 seconds to record a little data"
      sleep(10)

      puts "\nGet details of our running recording"
      puts @datasift.analysis.get hash

      puts "\nStop recording filter with hash #{hash}"
      filter = @datasift.analysis.stop hash
      puts filter

      puts "\nAnalyze stream"
      params = {
        :analysis_type => "freqDist",
        :parameters => {
          :threshold => 5,
          :target => "fb.author.age"
        }
      }
      filter = 'fb.content contains "starbucks"'
      puts @datasift.analysis.analyze(hash, params, filter)


    rescue DataSiftError => dse
      puts dse.message
    end
  end
end

AnalysisApi.new

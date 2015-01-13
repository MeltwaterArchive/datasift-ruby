require './auth'
class AnalysisApi < DataSiftExample
  def initialize
    super
    run_analysis
  end

  def run_analysis
    begin
      csdl = 'tag.shop "Starbucks" { fb.content contains "starbucks" }
        tag.shop "Peets" { fb.content contains_any "peet, peet\'s" }
        return { (fb.content any "coffee" OR fb.hashtags in "coffee")
        AND fb.language in "en" }'

      puts "Check this CSDL is valid: #{csdl}"
      puts "Valid? #{@datasift.analysis.valid? csdl}"

      puts "\nCompile my CSDL"
      compiled = @datasift.analysis.compile csdl
      hash = compiled[:data][:hash]
      puts "Hash: #{hash}"

      puts "\nStart recording filter with hash #{hash}"
      filter = @datasift.analysis.start(hash, 'Facebook Pylon Test Filter')
      puts filter[:data].to_json

      puts "\nSleep for 10 seconds to record a little data"
      sleep(10)

      puts "\nGet details of our running recording"
      puts @datasift.analysis.get(hash)[:data].to_json

      puts "\nStop recording filter with hash #{hash}"
      filter = @datasift.analysis.stop hash
      puts filter[:data].to_json

      puts "\nFrequency distribution analysis on fb.author.country"
      params = {
        :analysis_type => "freqDist",
        :parameters => {
          :threshold => 1,
          :target => "fb.author.country"
        }
      }
      puts @datasift.analysis.analyze(hash, params)[:data].to_json

      puts "\nFrequency distribution analysis on fb.author.age with filter"
      params = {
        :analysis_type => "freqDist",
        :parameters => {
          :threshold => 1,
          :target => "fb.author.age"
        }
      }
      filter = 'fb.content contains "starbucks"'
      puts @datasift.analysis.analyze(hash, params, filter)[:data].to_json

      puts "\nTime series analysis"
      params = {
        :analysis_type => "timeSeries",
        :parameters => {
          :interval => "hour",
          :span => 12
        }
      }
      puts @datasift.analysis.analyze(hash, params)[:data].to_json

      puts "\nTags analysis"
      puts @datasift.analysis.tags(hash)[:data].to_json

    rescue DataSiftError => dse
      puts dse.message
    end
  end
end

AnalysisApi.new

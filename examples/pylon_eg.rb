require './auth'
class AnalysisApi < DataSiftExample
  def initialize
    super
    run_analysis
  end

  def run_analysis
    begin
      csdl = 'return { fb.content contains "the" }'

      puts "Check this CSDL is valid: #{csdl}"
      puts "Valid? #{@datasift.pylon.valid?(csdl: csdl)}"

      puts "\nCompile my CSDL"
      compiled = @datasift.pylon.compile csdl
      hash = compiled[:data][:hash]
      puts "Hash: #{hash}"

      puts "\nStart recording filter with hash #{hash}"
      filter = @datasift.pylon.start(
        hash: hash,
        name: 'Facebook Pylon Test Filter'
      )
      puts filter[:data].to_json

      puts "\nSleep for 10 seconds to record a little data"
      sleep(10)

      puts "\nGet details of our running recording"
      puts @datasift.pylon.get(hash)[:data].to_json

      puts "\nFrequency distribution analysis on fb.author.country"
      params = {
        analysis_type: 'freqDist',
        parameters: {
          threshold: 1,
          target: 'fb.author.country'
        }
      }
      puts @datasift.pylon.analyze(
        hash: hash,
        parameters: params
      )[:data].to_json

      puts "\nFrequency distribution analysis on fb.author.age with filter"
      params = {
        analysis_type: 'freqDist',
        parameters: {
          threshold: 1,
          target: 'fb.author.age'
        }
      }
      filter = 'fb.content contains "starbucks"'
      puts @datasift.pylon.analyze(
        hash: hash,
        parameters: params,
        filter: filter
      )[:data].to_json

      puts "\nTime series analysis"
      params = {
        analysis_type: 'timeSeries',
        parameters: {
          interval: 'hour',
          span: 12
        }
      }
      filter = ''
      start_time = Time.now.to_i - (60 * 60 * 12) # 7 days ago
      end_time = Time.now.to_i
      puts @datasift.pylon.analyze(
        hash: hash,
        parameters: params,
        filter: filter,
        start_time: start_time,
        end_time: end_time
      )[:data].to_json

      puts "\nTags analysis"
      puts @datasift.pylon.tags(hash)[:data].to_json

      puts "\nStop recording filter with hash #{hash}"
      puts @datasift.pylon.stop(hash)[:data].to_json

      rescue DataSiftError => dse
        puts dse.message
    end
  end
end

AnalysisApi.new

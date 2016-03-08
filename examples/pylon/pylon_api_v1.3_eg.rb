##
# This script runs through all PYLON API endpoints using v1.3 of the API
##

require './../auth'
class AnalysisApi < DataSiftExample
  def initialize
    super
    run_analysis
  end

  def run_analysis
    begin
      puts "Create a new identity to make PYLON API calls"
      identity = @datasift.account_identity.create(
        "RUBY_LIB_#{Time.now.to_i}",
        "active",
        false
      )
      identity_id = identity[:data][:id]
      puts identity[:data].to_json

      puts "\nCreate a Token for our Identity"
      token = @datasift.account_identity_token.create(
        identity_id,
        'facebook',
        '125595667777713|5aef9cfdb31d8be64b87204c3bca820f'
      )
      puts token[:data].to_json

      puts "\nNow make PYLON API calls using the Identity's API key"
      @pylon_config = @config.dup
      @pylon_config.merge!(
        api_key: identity[:data][:api_key],
        api_version: 'v1.3'
      )
      @datasift = DataSift::Client.new(@pylon_config)

      csdl = "return { fb.all.content any \"data, #{Time.now}\" }"

      puts "Check this CSDL is valid: #{csdl}"
      puts "Valid? #{@datasift.pylon.valid?(csdl)}"

      puts "\nCompile my CSDL"
      compiled = @datasift.pylon.compile csdl
      hash = compiled[:data][:hash]
      puts "Hash: #{hash}"

      puts "\nStart recording with hash #{hash}"
      recording = @datasift.pylon.start(
        hash,
        'Facebook Pylon Test Recording'
      )
      puts recording[:data].to_json

      puts "\nSleep for 10 seconds to record a little data"
      sleep(10)

      puts "\nGet details of our running recording by ID"
      puts @datasift.pylon.get('', recording[:data][:id])[:data].to_json

      puts "\nYou can also list running recordings"
      puts @datasift.pylon.list[:data].to_json

      puts "\nFrequency distribution analysis on fb.author.country"
      params = {
        analysis_type: 'freqDist',
        parameters: {
          threshold: 3,
          target: 'fb.author.country'
        }
      }
      puts @datasift.pylon.analyze(
        '',
        params,
        '',
        nil,
        nil,
        recording[:data][:id]
      )[:data].to_json

      puts "\nFrequency distribution analysis on fb.author.age with filter"
      params = {
        analysis_type: 'freqDist',
        parameters: {
          threshold: 1,
          target: 'fb.author.age'
        }
      }
      filter = 'fb.parent.content any "facebook"'
      puts @datasift.pylon.analyze(
        '',
        params,
        filter,
        nil,
        nil,
        recording[:data][:id]
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
      start_time = Time.now.to_i - (60 * 60 * 24 * 7) # 7 days ago
      end_time = Time.now.to_i
      puts @datasift.pylon.analyze(
        '',
        params,
        filter,
        start_time,
        end_time,
        recording[:data][:id]
      )[:data].to_json

      puts "\nFrequency Distribution with nested queries. Find the top three " \
        "age groups for each gender by country"
      filter = ''
      params = {
        analysis_type: 'freqDist',
        parameters: {
          threshold: 4,
          target: 'fb.author.country'
        },
        child: {
          analysis_type: 'freqDist',
          parameters: {
            threshold: 2,
            target: 'fb.author.gender'
          },
          child: {
            analysis_type: 'freqDist',
            parameters: {
              threshold: 3,
              target: 'fb.author.age'
            }
          }
        }
      }
      start_time = Time.now.to_i - (60 * 60 * 24 * 7)
      end_time = Time.now.to_i
      puts @datasift.pylon.analyze(
        '',
        params,
        filter,
        start_time,
        end_time,
        recording[:data][:id]
      )[:data].to_json

      puts "\nTags analysis"
      puts @datasift.pylon.tags('',recording[:data][:id])[:data].to_json

      puts "\nGet Public Posts"
      puts @datasift.pylon.sample(
        '',
        10,
        Time.now.to_i - (60 * 60), # from 1hr ago
        Time.now.to_i, # to 'now'
        'fb.content contains_any "your, filter, terms"',
        recording[:data][:id]
      )[:data].to_json

      puts "\nv1.3+ of the API allows you to update the name or hash of recordings;"
      puts "\nBefore update:"
      puts @datasift.pylon.get(recording[:data][:id])[:data].to_json

      new_hash = @datasift.pylon.compile("fb.content any \"data, #{Time.now}\"")[:data][:hash]

      puts "\nAfter update:"
      puts @datasift.pylon.update(
        recording[:data][:id],
        new_hash,
        "Updated at #{Time.now}"
      )[:data].to_json

      puts "\nStop recording filter with the recording ID #{recording[:data][:id]}"
      puts @datasift.pylon.stop('', recording[:data][:id])[:data].to_json
      sleep(3)
      puts "\nYou can also restart a stopped recording by recording ID #{recording[:data][:id]}"
      puts @datasift.pylon.restart(recording[:data][:id])[:data].to_json

      # Cleanup.
      # Stop the recording again to clean up
      sleep(3)
      @datasift.pylon.stop('', recording[:data][:id])[:data].to_json
      # Disable the identity created for this example
      @datasift = DataSift::Client.new(@config)
      @datasift.account_identity.update(identity_id, '', 'disabled')

      rescue DataSiftError => dse
        puts dse.inspect
    end
  end
end

AnalysisApi.new

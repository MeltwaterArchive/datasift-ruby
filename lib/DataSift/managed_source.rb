require 'yajl/json_gem'
### Usage ###
# user = DataSift::User.new(config['username'], config['api_key'])
# user.createManagedSource(:token => "CAAIUKbXn8xsBAILlxGCZADEZAM87tRqJXo9OqWskCs6jej3wfQ1LRRZAgHJQEZCHU0ABBXDwiq9o7D4uytC5LpsAcx7oiDusagsJiKtmPaZBeMkuGh4jYt1zsXo4EQuZCWPcZAIdQQLZBtjTpQlbbAZCTuJ4SSrlmOPQZD", :source_type => "facebook_page", :name => "test", :parameters=> {:likes => true, :posts_by_others =>  true, :comments => true}, :resources => [{ :url =>  "http://www.facebook.com/theguardian", :title =>  "The Guardian", :id => 10513336322 } ] )

module DataSift
  #The ManagedSource class represents a ManagedSource query.
  class ManagedSource
    #The ID of this Managed Source
    attr_reader :managed_source_id
    #The Managed Source type
    attr_reader :source_type
    #The current status of this Managed Source.
    attr_reader :status
    #The title for this Managed Source.
    attr_reader :name
    #The date/time when this Managed Source was created.
    attr_reader :created_at
    #The Managed Source source_type
    attr_reader :source_type
    #The Managed Source parameters
    attr_reader :parameters
    #The Managed Source resources
    attr_reader :resources
    #The Managed Source token
    attr_reader :token
    #The Managed Source auth
    attr_reader :auth
    #Api raw response
    attr_reader :raw_attributes

    #Constructor. Pass all parameters to create a new Managed Source, or provide a User object and a managed_source_id to load an existing Managed Source from the API.
    #=== Parameters
    #* +user+ - The DataSift::User object.
    def initialize(user, hash)
      raise InvalidDataError, 'Please supply a valid User object when creating a Managed Source object.' unless user.is_a? DataSift::User
      @user = user

      if hash.kind_of?(Hash)
        if hash.has_key?('id')
          # Initialising from an array
          @managed_source_id = hash['id']
          initFromArray(hash)
        else
          @source_type = hash[:source_type]
          @name = hash[:name]
          @parameters = hash[:parameters]
          @resources = hash[:resources]
          @auth = hash[:auth]
        end
      else
        # Fetching from the API
        @managed_source_id = hash
        reloadData()
      end
    end

    #Get a single Managed Source by ID.
    #=== Parameters
    #* +id+ - The Managed Source ID.
    #=== Returns
    #A ManagedSource object
    def self.get(user, managed_source_id)
      return new(user, user.callAPI('source/get', { 'id' => managed_source_id }))
    end

    def self.list(user, page = 1, per_page = 20, source_type = '')
      begin
        res = user.callAPI(
        'source/get', {
          'page' => page,
          'per_page' => per_page,
          'source_type' => source_type
          })
          retval = { 'count' => res['count'], 'managed_sources' => [] }
          for source in res['sources']
           retval['managed_sources'].push(new(user, source))
          end
          retval
        rescue APIError => err
          case err.http_code
          when 400
            #Missing or invalid parameters
            raise InvalidDataError, err
          else
            raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
          end
        end
    end

    #Call the DataSift API to create the Managed Source
    def create()
      raise InvalidDataError, 'This Managed Source has already been created' unless not @managed_source_id

      begin
        res = @user.callAPI(
        'source/create', {
          'source_type' => @source_type,
          'name' => @name,
          'parameters' => @parameters.to_json,
          'resources' => @resources.to_json,
          'auth' => @auth.to_json
        })
        raise InvalidDataError, 'Prepared successfully but no managed_source_id ID in the response' unless res.has_key?('id')
        @managed_source_id = res['id']

      rescue APIError => err
        case err.http_code
        when 400
          raise InvalidDataError, err
        else
          raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
        end
      end

      # Reload the data so we get the created_at date, initial status and the rest.
      reloadData()
    end

    #Reload the data for this object from the API.
    def reloadData()
      #Can't do this without a playback ID
      raise InvalidDataError, 'Cannot reload the data with a Managed Source with no Managed Source ID' unless @managed_source_id

      begin
        initFromArray(@user.callAPI('source/get', { 'id' => @managed_source_id }))
      rescue APIError => err
        case err.http_code
        when 400
          raise InvalidDataError, err
        else
          raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
        end
      end
    end

    #Initialise this object from the data in a Hash.
 		#=== Parameters
    #* +data+ - The Hash containing the data.
    def initFromArray(data)
      raise APIError, 'No managed source ID in the response' unless data.has_key?('id')
      raise APIError, 'Incorrect managed source ID in the response' unless not @managed_source_id or data['id'] == @managed_source_id
      @managed_source_id = data['id']

      raise APIError, 'No name in the response' unless data.has_key?('name')
      @name = data['name']

      raise APIError, 'No auth in the response' unless data.has_key?('auth')
      @auth = data['auth']

      raise APIError, 'No created at timstamp in the response' unless data.has_key?('created_at')
      @created_at = DateTime.strptime(String(data['created_at']), '%s')

      raise APIError, 'No status in the response' unless data.has_key?('status')
      @status = data['status']

      raise APIError, 'No source_type in the response' unless data.has_key?('source_type')
      @source_type = data['source_type']

      raise APIError, 'No parameters in the response' unless data.has_key?('parameters')
      @parameters = data['parameters']

      raise APIError, 'No resources in the response' unless data.has_key?('resources')
      @resources = data['resources']

      @raw_attributes = data

      return true
    end

    #Start this Managed Source query.
    def start()
      raise InvalidDataError, 'Cannot start a Managed souce query that hasn\'t been created' unless @managed_source_id

      begin
        res = @user.callAPI('source/start', { 'id' => @managed_source_id })
      rescue APIError => err
        case err.http_code
        when 400
          # Missing or invalid parameters
          raise InvalidDataError, err
        when 404
          # Managed Source not found
          raise InvalidDataError, err
        else
          raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
        end
      end
    end

    #Stop this Managed Source
    def stop()
      raise InvalidDataError, 'Cannot stop a Managed Source query that hasn\'t been prepared' unless @managed_source_id

      begin
        res = @user.callAPI('source/stop', { 'id' => @managed_source_id })
      rescue APIError => err
        case err.http_code
        when 400
          # Missing or invalid parameters
          raise InvalidDataError, err
        when 404
          # Managed Source not found
          raise InvalidDataError, err
        else
          raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
        end
      end
    end

    #Delete this Managed Source
    def delete()
      raise InvalidDataError, 'Cannot delete a Managed source query that hasn\'t been prepared' unless @managed_source_id

      begin
        @user.callAPI('source/delete', { 'id' => @managed_source_id })
      rescue APIError => err
        case err.http_code
        when 400
          # Missing or invalid parameters
          raise InvalidDataError, err
        when 404
          # Managed Source not found
          raise InvalidDataError, err
        else
          raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
        end
      end
    end

    #Page through recent Managed Sources log entries
    #=== Parameters
    #* +page+ - The page number to get.
    #* +per_page+ - The number of items per page.
    #=== Returns
    #A Hash containing...
    #* +count+ - The total number of matching log entries.
    #* +log_entries+ - An array of Hashes where each Hash is a log entry.
    def getLogs(page = 1, per_page = 20)
      begin
        raise InvalidDataError, 'The specified page number is invalid' unless page >= 1
        raise InvalidDataError, 'The specified per_page value is invalid' unless per_page >= 1

        params = {
          'id'        => @managed_source_id,
          'page'      => page,
          'per_page'  => per_page
        }

        return @user.callAPI('source/log', params)
      rescue APIError => err
        case err.http_code
        when 400
          # Missing or invalid parameters
          raise InvalidDataError, err
        else
          raise APIError.new(err.http_code), 'Unexpected APIError code: ' + err.http_code.to_s + ' [' + err.message + ']'
        end
      end
    end

  end
end
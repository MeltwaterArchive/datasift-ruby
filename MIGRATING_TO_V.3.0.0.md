MIGRATING TO V.3.0.0
================================

Breaking Changes
----------------
Earlier versions of the DataSift library are incompatible with 3.x.x. 3.0.0 is a complete re-design. In order to continue delivering better features and performance some architectural changes have been made which make backwards compatibility very difficult and in some cases impractical.

Features
--------
* Live streaming now uses multi-threaded WebSockets, so you can subscribe and unsubscribe from stream hashes.
* This update ensures that the Ruby client library now supports all API features that were missing from prior versions of the client.
* This includes adding support for Historics Previews, and the [Pull Connector](http://dev.datasift.com/blog/pullingdata).
* Previous versions made API requests through a ```DataSift::User``` object. From v.3.0.0, we have moved to a more semantically correct ```DataSift::Client``` object.

Code
====

## Authentication
From v.3.0.0 of the Ruby client, we have dropped the concept of the ```DataSift::User``` object, and now use a ```DataSift::Client``` object for all API calls.

### Authentication: < 3.0.0

```ruby
config = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'config.yml')))
user = DataSift::User.new(config['username'], config['api_key'])
```

### Authentication: 3.0.0+
From v.3.0.0+ you begin by providing a configuration object to the DataSift client. From here the client instance gives you access to the rest of the DataSift API. This is organized in a similar way to the DataSift [REST API documentation](http://dev.datasift.com/docs/rest-api) except where it didn't make sense to do so.

```ruby
@config = {:username => 'DATASIFT_USERNAME', :api_key => 'DATASIFT_API_KEY', :enable_ssl => true}
@datasift = DataSift::Client.new(@config)
```


## Core
* @datasift.valid? csdl
* @datasift.compile csdl
* @datasift.usage [period]
* @datasift.dpu hash
* @datasift.balance

Below are examples of how to compile, then check the DPU cost of a CSDL statement, then check your API usage. These examples both assume you have correctly authenticated with the API.

### Core: < 3.0.0
```ruby
csdl = 'interaction.content contains "datasift"'
definition = user.createDefinition(csdl)
dpu = definition.getDPUBreakdown()
usage = user.getUsage()
```

### Core: 3.0.0+
```ruby
csdl = interaction.content contains "datasift"'
stream = @datasift.compile csdl
dpu = @datasift.dpu stream[:data][:hash]
usage = @datasift.usage
```


## Live Streaming
The Live Streaming API is now accessed via WebSockets using the [websocket_td](https://github.com/zcourts/websocket-td) gem, rather than streaming over HTTP. This allows us to use the ```stream.subscribe(hash, on_message)``` and ```stream.unsubscribe hash``` methods to asynchronously subscribe and unsubscribe from streams, while still streaming data.
Please note, the examples below include only the mandatory callback methods, and do not include any additional error handling. The examples included in the client library itself do include some very basic error handling.

### Core: < 3.0.0
```ruby
consumer.consume(true) do |interaction|
  if interaction
    puts interaction.to_s
  end
end
```


### Core: 3.0.0+
```ruby
def stream(hash)
  on_delete  = lambda { |stream, m| puts m }
  on_error   = lambda { |stream, e| puts "An error has occurred: #{message}" }
  on_message = lambda { |message, stream, hash| puts message }

  on_datasift_message = lambda do |stream, message, hash|
    puts "DataSift Message #{hash} ==> #{message}"
  end

  conn = DataSift::new_stream(@config, on_delete, on_error, on_open, on_close)
  conn.on_datasift_message = on_datasift_message
  conn.stream.read_thread.join
end
```

#### on_delete event
on_delete is called when your stream receives a [delete notification](http://dev.datasift.com/docs/resources/twitter-deletes) from Twitter, notifying you that a Tweet you may have received has been deleted.

#### on_error event
on_error is called in cases where where an exception occurs during streaming.

#### on_message event
on_message is called when we receive [user status messages](http://dev.datasift.com/docs/resources/twitter-user-status-messages) from Twitter.


## Push
* @datasift.push.valid? @params
* @datasift.create @params
* @datasift.push.pause subscription_id
* @datasift.push.resume subscription_id
* @datasift.push.update @params.merge({:id => subscription_id, :name => 'Updated name'})
* @datasift.push.stop subscription_id
* @datasift.push.delete subscription_id
* @datasift.push.log
* @datasift.push.get_by_subscription subscription_id
* @datasift.push.get
* @datasift.pull

Below are some simple examples, showing you how to create, pause, resume, update, get, stop then delete a Push Subscription:

### Push: < 3.0.0
```ruby
definition = env.user.createDefinition(csdl)

pushdef = env.user.createPushDefinition()
pushdef.output_type = output_type

# Add your output parameters to your Push Definition
while env.args.size() > 0
  k, v = env.args.shift.split('=', 2)
  pushdef.output_params[k] = v
end

sub = pushdef.subscribeDefinition(definition, name)

sub.pause()
sub.resume()
sub.save()
sub.stop()
sub.delete()
```


### Push: 3.0.0+
```ruby
subscription = create_push(hash)
subscription_id = subscription[:data][:id]

@datasift.push.pause subscription_id
@datasift.push.resume subscription_id
@datasift.push.update @params.merge({:id => subscription_id, :name => 'New name'})
@datasift.push.get_by_subscription subscription_id
@datasift.push.stop subscription_id
@datasift.push.delete subscription_id
```


## Historics
* @datasift.historics.prepare(hash, start, end, 'My ruby historics')
* @datasift.historics.start id
* @datasift.historics.stop id
* @datasift.historics.status(start, end_time)
* @datasift.historics.update(id, 'The new name of my historics')
* @datasift.historics.delete id
* @datasift.historics.get_by_id id
* @datasift.historics.get

Below are some simple examples demonstrating how to check the status of the Historics archive for a given timeframe, prepare an Historic, then start, get, stop and delete the Historic.

### Historics: < 3.0.0
```ruby
start_time = Time.now.to_i - 7200
end_time   = start + 3600

# /historics/status not implemented in < 3.0.0
definition = env.user.createDefinition(csdl)
historic = definition.createHistoric(start_time, end_time, sources, sample, name)

historic.prepare()
historic.start()
user.getHistoric(historic.id)
historic.stop()
historic.delete()
```

### Historics: 3.0.0+
```ruby
start_time = Time.now.to_i - 7200
end_time   = start + 3600

@datasift.historics.status(start_time, end_time)

historics = @datasift.historics.prepare(hash, start_time, end_time, 'My Historic')
id = historics[:data][:id]

create_push(id, true)

@datasift.historics.start id
@datasift.historics.get_by_id id
@datasift.historics.stop id
@datasift.historics.delete id
```

## Historics Preview
* @datasift.historics_preview.create(hash, parameters, start, end)
* @datasift.historics_preview.get id

Historics preview was not available before v.3.0.0. The example below demonstrates how to create, then get the results of an Historics preview:

### Hisotrics Preview: 3.0.0+
```ruby
parameters = 'interaction.author.link,targetVol,hour;interaction.type,freqDist,10'
start      = Time.now.to_i - (3600 * 48) # 48hrs ago
source     = @datasift.historics_preview.create(hash, parameters, start)
@datasift.historics_preview.get source[:data][:id]
```


## Managed Sources
* @datasift.managed_source.create(source_type, name, parameters, resources, auth)
* @datasift.managed_source.update(id, source_type, name, parameters, resources, auth)
* @datasift.managed_source.delete id
* @datasift.managed_source.log id
* @datasift.managed_source.get id
* @datasift.managed_source.stop id
* @datasift.managed_source.start id

Below is a Managed Sources example, using each of the Managed Sources API endpoints:

### Managed Sources < 3.0.0
```ruby
parameters = {:likes => true, :comments => true}
resources  = [{:parameters => {:type => 'tag', :value => 'coffee'}}]
auth       = [{:parameters => {:value => '10942112.1fb234f.8713bcf4d5b44ece801022f6fa4b9e1b'}}]

user   = DataSift::User.new(config['username'], config['api_key'], false)
source = user.createManagedSource(:source_type => 'instagram', :name => '#Coffee Pics', :parameters => parameters, :resources => resources, :auth => auth)

source.start
user.getManagedSource(source.managed_source_id)
user.getManagedSourcesLog(source.managed_source_id)
source.stop
source.delete
```

### Managed Sources 3.0.0+
```ruby
parameters = {:likes => true, :comments => true}
resources  = [{:parameters => {:type => 'tag', :value => 'coffee'}}]
auth       = [{:parameters => {:value => '10942112.1fb234f.8713bcf4d5b44ece801022f6fa4b9e1b'}}]

source = @datasift.managed_source.create('instagram', '#Coffee Pics', parameters, resources, auth)
id     = source[:data][:id]

@datasift.managed_source.start id
source = @datasift.managed_source.get id
# Note that in the line below, we pass the auth object returned from a /source/get call back into the /source/update statement. Passing the original auth object will fail
@datasift.managed_source.update(id, 'instagram', 'Updated source name', parameters, resources, source[:data][:auth])
@datasift.managed_source.log id
@datasift.managed_source.stop id
@datasift.managed_source.delete id
```



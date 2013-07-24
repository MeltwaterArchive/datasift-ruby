#This is the base file for the DataSift API library. Require this file to get
#access to the full library functionality.
require 'rubygems'

dir = File.dirname(__FILE__)
require dir + '/DataSift/exceptions'
require dir + '/DataSift/apiclient'
require dir + '/DataSift/user'
require dir + '/DataSift/definition'
require dir + '/DataSift/historic'
require dir + '/DataSift/push_definition'
require dir + '/DataSift/push_subscription'
require dir + '/DataSift/stream_consumer'
require dir + '/DataSift/stream_consumer_http'
require dir + '/DataSift/managed_source'
require dir + '/DataSift/ManagedSources/facebook_page'
require dir + '/DataSift/ManagedSources/googleplus'
require dir + '/DataSift/ManagedSources/instagram'
require dir + '/DataSift/ManagedSources/yammer'

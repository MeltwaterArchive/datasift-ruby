#
# datasift.rb - DataSift module base file
#
# Copyright (C) 2011 MediaSift Ltd
#
# == Overview
#
# This is the base file for the DataSift API library. Require this file to get
# access to the full library functionality.
#
require 'rubygems'

dir = File.dirname(__FILE__)
require dir + '/DataSift/exceptions'
require dir + '/DataSift/user'
require dir + '/DataSift/definition'
require dir + '/DataSift/stream_consumer'
require dir + '/DataSift/stream_consumer_http'

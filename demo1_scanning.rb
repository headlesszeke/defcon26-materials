#!/usr/bin/env ruby
# coding: utf-8
require 'socket'
require 'timeout'
require 'expect'

BROADCAST_ADDR = "255.255.255.255"
BIND_ADDR = "0.0.0.0"
PORT = 41794
CTP_PORT = 41795
IFACE = ARGV[0]
timeout = 5

# socket setup
socket = UDPSocket.new
socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BINDTODEVICE, IFACE) if IFACE
socket.bind(BIND_ADDR, PORT)

# magic probe
hostname = "blah" # any string will do
buffer = "\x14\x00\x00\x00\x01\x04\x00\x03\x00\x00" + hostname + "\x00" * (256 - hostname.length) # padded with null bytes up to 256

puts "sending discover request"
socket.send(buffer,0,BROADCAST_ADDR,PORT)

puts "waiting #{timeout} second#{"s" if timeout > 1} for responses..."
puts ""

while true
  begin
    Timeout::timeout(timeout) do
      resp, addr = socket.recvfrom(1024)
      if resp && resp[0] == "\x15"
        puts addr.last.center(21,"-")
        puts "Hostname:\t#{resp[10,256].gsub("\x00","")}"
        info = resp[266,128].gsub("\x00","")
        model = info.match(/^\S+/)
        if model
          puts "Model:\t\t#{model[0]}"
        end
        firmware = info.match(/\[v((?:\d+\.)*\d+)/)
        if firmware
          puts "Firmware:\t#{firmware[1]}"
        end
        build = info.match(/\((.+?)\)/)
        if build
          puts "Build date:\t#{build[1]}"
        end
        printf "CTP console:\t"
        begin
          s = TCPSocket.new(addr.last,CTP_PORT)

          s.write("\r\n")
          if s.expect(/>$/,1)
            printf "OPEN ("
            s.write("whoami\r\n")
            resp = s.expect(/(Administrator|Unknown|Operator|Power User|Guest)/,1)
            if resp
              printf "#{resp.last})"
            else
              printf "Unknown)"
            end
            s.write("bye\r\n")
          else
            printf "CLOSED"
          end
          
          s.close
        rescue Errno::ECONNREFUSED
          printf "CLOSED"
        end
        puts ""
      end
    end
  rescue Timeout::Error, Interrupt
    break
  end
end

# socket teardown
socket.close

puts "-" * 21
puts "done"

# © 2018, Trend Micro Incorporated

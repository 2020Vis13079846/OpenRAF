#
#  vps.rb
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

require 'httparty'

def start_vps()
    ##################################
    # OpenRAF uses ngrok VPS
    ##################################
    #
    # 1. Download ngrok from ngrok.com
    #
    # 2. Install ngrok to PATH
    #
    # 3. Execute ruby vps.rb
    #
    ##################################
    system("ngrok tcp 8080 > /dev/null &")
    sleep(5)
    begin
        response = HTTParty.get 'http://localhost:4040/api/tunnels'
        json = JSON.parse response.body
        new_sms_url = json['tunnels'].first['public_url']
        vps = new_sms_url
        puts 'VPS started successfully!'
    rescue Errno::ECONNREFUSED
        puts 'Failed to start VPS!'
        exit
    end
    open('/usr/local/share/OpenRAF/vps/port.txt', 'w') { |f|
        f.puts vps[21..-1]
    }
    open('/usr/local/share/OpenRAF/vps/host.txt', 'w') { |f|
        f.puts vps[6..-7]
    }
end

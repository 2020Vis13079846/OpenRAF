#
#  shell.rb
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

w = "\033[1;33m[!] \033[0m"
g = "\033[1;34m[*] \033[0m"
e = "\033[1;31m[-] \033[0m"
s = "\033[1;32m[+] \033[0m"

puts "#{w}OpenRAF uses localhost:8080 as VPS."
loop do
    print "localhost:8080> "
    gets()

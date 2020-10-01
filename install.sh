#!/bin/bash

#
#  install.sh
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

OBJ_PATH="/usr/local/share/OpenRAF"

mkdir $OBJ_PATH
cp -r vps $OBJ_PATH
cp -r ars $OBJ_PATH
cp -r atk $OBJ_PATH

gem install httparty

make openraf

{
    cp .build/openraf /bin
    chmod +x /bin/openraf
    cp .build/openraf /usr/local/bin
    chmod +x /usr/local/bin/openraf
} &> /dev/null

make clean

#!/bin/bash

#
#  uninstall.sh
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

OBJ_PATH="/usr/local/share/OpenRAF"

rm -rf $OBJ_PATH

{
    rm /bin/openraf
    rm /usr/local/bin/openraf
} &> /dev/null

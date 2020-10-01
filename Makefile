#
#  Makefile
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

openraf:
	@echo "Building OpenRAF to .build/openraf"
	@mkdir .build
	@g++ openraf.cc -o .build/openraf

clean:
	@rm -rf .build

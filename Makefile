#
#  Makefile
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

CXX        = g++
CXXFLAGS   =
LDFLAGS    =

TARGET     = .build/openraf

Q          = @
MKDIR      = mkdir
RM         = rm
MSG        = echo

openraf:
	$(Q) $(MSG) "Building OpenRAF to .build/openraf"
	$(Q) $(MKDIR) .build
	$(Q) $(CXX) openraf.cc -o $(TARGET)

clean:
	$(Q) $(RM) -rf .build

#
#  Makefile
#  OpenRAF
#
#  Created by Ivan Nikolsky on 2020.
#  Copyright © 2020 Ivan Nikolsky. All rights reserved.
#

CXX        = g++
CXXFLAGS   = -Wall -pedantic -Wextra -Iinclude
LDFLAGS    =

TARGET     = .build/openraf

Q          = @
MKDIR      = mkdir
RM         = rm
MSG        = echo

all: openraf

openraf:
	$(Q) $(MSG) "Building OpenRAF to .build/openraf"
	$(Q) $(MKDIR) .build
	$(Q) $(CXX) openraf.cc -o $(TARGET) $(CXXFLAGS) $(LDFLAGS)

clean:
	$(Q) $(RM) -rf .build

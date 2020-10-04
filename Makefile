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
GEM        = gem

Q          = @
MKDIR      = mkdir
CHMOD      = chmod
RM         = rm
CP         = cp
MSG        = echo

OBJ_PATH   = /usr/local/share/OpenRAF

all: dependencies openraf install clean

dependencies:
	$(Q) $(GEM) install httparty

openraf:
	$(Q) $(MSG) "Building OpenRAF to .build/openraf"
	$(Q) $(MKDIR) -p .build
	$(Q) $(CXX) openraf.cc -o $(TARGET) $(CXXFLAGS) $(LDFLAGS)

install:
	$(Q) $(MKDIR) -p $(OBJ_PATH)
	$(Q) $(CP) -r vps ars atk $(OBJ_PATH)
    	$(Q) $(CP) .build/openraf /usr/local/bin
    	$(Q) $(CHMOD) +x /usr/local/bin/openraf

uninstall:
	$(Q) $(RM) -rf $(OBJ_PATH)
	$(Q) $(RM) /usr/local/bin/openraf

clean:
	$(Q) $(RM) -rf .build

################################################################################
#
#   Copyright (c) 2017 Minoca Corp.
#
#    This file is licensed under the terms of the GNU General Public License
#    version 3. Alternative licensing terms are available. Contact
#    info@minocacorp.com for details. See the LICENSE file at the root of this
#    project for complete licensing information.
#
#   Binary Name:
#
#       JSON (Build Shared)
#
#   Abstract:
#
#       This shared Chalk module implements JSON dumping and loading.
#
#   Author:
#
#       Evan Green 19-May-2017
#
#   Environment:
#
#       POSIX
#
################################################################################

BINARY := json.so

BINARYTYPE = so

BUILD = yes

BINPLACE = tools/lib/chalk1

VPATH += ..:

include $(SRCDIR)/../../sources

OS ?= $(shell uname -s)

ifeq ($(OS),$(filter Windows_NT cygwin,$(OS)))

BINARY := json.dll

OBJS += $(WIN32_OBJS)

DYNLIBS = $(OBJROOT)/os/apps/ck/lib/build/dynamic/chalk.dll

else

OBJS += $(POSIX_OBJS)

endif

include $(SRCROOT)/os/minoca.mk

ifeq ($(OS),Darwin)

DYNLIBS = $(OBJROOT)/os/apps/ck/lib/build/dynamic/libchalk.1.dylib

endif


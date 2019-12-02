UNAME := $(shell uname)

ifndef HASHLINK_SRC
	HASHLINK_SRC = ../../../hashlink
endif

LIBHL=libhl.xxx

SDKVER=1.139.2

ifeq ($(UNAME),Darwin)
OS=osx
# universal lib in osx32 dir
LIBARCH=32
FNAME=DevelopmentKit_${SDKVER}_Darwin_universal
LIBHL=libhl.dylib
LFLAG_GALAXY=-lGalaxy
else
OS=linux
LIBARCH=64
FNAME=DevelopmentKit_${SDKVER}_Linux_GCC92_64bit
LIBHL=libhl.so
LFLAG_GALAXY=-lGalaxy64
endif

SDKVER=1.139.2
#SDKURL="http://cdn.gog.com/open/galaxy/sdk/${SDKVER}/Downloads/${FNAME}.tar.gz"

CFLAGS = -Wall --std=c++11 -O3 -I src -I ../sdk/Include -I native/include -fPIC
LFLAGS = -lhl $(LFLAG_GALAXY) -lstdc++ -L native/lib/$(OS)$(LIBARCH) -L ../sdk/Libraries

SRC = src/common.o

all: ${SRC}
	${CC} ${CFLAGS} -shared -o gog.hdll ${SRC} ${LFLAGS}

prepare:
	rm -rf native/lib/$(OS)$(LIBARCH)
	mkdir -p native/include
	mkdir -p native/lib/$(OS)$(LIBARCH)
	cp $(HASHLINK_SRC)/src/hl.h native/include/
	cp $(HASHLINK_SRC)/$(LIBHL) native/lib/$(OS)$(LIBARCH)/

.SUFFIXES : .cpp .o

.cpp.o :
	${CC} ${CFLAGS} -o $@ -c $<
	
clean_o:
	rm -f ${SRC}

clean: clean_o
	rm -f gog.hdll


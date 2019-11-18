LBITS := $(shell getconf LONG_BIT)

UNAME := $(shell uname)

ifndef ARCH
	ARCH = $(LBITS)
endif

LIBARCH=$(ARCH)

SDKVER=1.139.2
ifeq ($(UNAME),Darwin)
OS=osx
# universal lib in osx32 dir
LIBARCH=32
FNAME=DevelopmentKit_${SDKVER}_Darwin_universal
else
OS=linux
FNAME=DevelopmentKit_${SDKVER}_Linux_GCC92_${ARCH}bit
endif

SDKVER=1.139.2
SDKURL="http://cdn.gog.com/open/galaxy/sdk/${SDKVER}/Downloads/${FNAME}.tar.gz"

CFLAGS = -Wall --std=c++11 -O3 -I src -I ../sdk/Include -fPIC
LFLAGS = -lhl -lGalaxy -lstdc++ -L native/lib/$(OS)$(LIBARCH) -L ../sdk/Libraries

SRC = src/common.o

prepare:
	mkdir -p native/lib
	mkdir -p native/include
	mkdir -p native/lib/$(OS)$(LIBARCH)

	#sdk install
	rm -rf ../sdk
	rm ../gog_sdk.tar.gz
	
	curl ${SDKURL} -o ../gog_sdk.tar.gz
	cd ..;  tar zxvf gog_sdk.tar.gz; mv ${FNAME} sdk;
	
	cp ../../../hashlink/src/hl.h native/include/
	rm -rf git/native/lib/$(OS)$(ARCH)
	cp ../../../hashlink/libhl.dylib native/lib/$(OS)$(LIBARCH)/

all: ${SRC}
	${CC} ${CFLAGS} -shared -o gog.hdll ${SRC} ${LFLAGS}

.SUFFIXES : .cpp .o

.cpp.o :
	${CC} ${CFLAGS} -o $@ -c $<
	
clean_o:
	rm -f ${SRC}

clean: clean_o
	rm -f gog.hdll


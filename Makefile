LBITS := $(shell getconf LONG_BIT)

UNAME := $(shell uname)

ifndef ARCH
	ARCH = $(LBITS)
endif

LIBARCH=$(ARCH)
ifeq ($(UNAME),Darwin)
OS=osx
# universal lib in osx32 dir
LIBARCH=32
else
OS=linux
endif

CFLAGS = -Wall --std=c++11 -O3 -I src -I Include -fPIC
LFLAGS = -lhl -lGalaxy -lstdc++ -L native/lib/$(OS)$(LIBARCH) -L Libraries

SRC = src/common.o

all: ${SRC}
	${CC} ${CFLAGS} -shared -o gog.hdll ${SRC} ${LFLAGS}

.SUFFIXES : .cpp .o

.cpp.o :
	${CC} ${CFLAGS} -o $@ -c $<
	
clean_o:
	rm -f ${SRC}

clean: clean_o
	rm -f gog.hdll


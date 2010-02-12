TARGET = SIMULATOR

PLATFORM_SIMULATOR = /Developer/Platforms/iPhoneSimulator.platform
PLATFORM_IPHONEOS = /Developer/Platforms/iPhoneOS.platform

DEVEL = $(PLATFORM_$(TARGET))/Developer

ARCH_SIMULATOR = i386
ARCH_IPHONEOS = armv6

ARCH = $(ARCH_$(TARGET))

CXXINCLUDE = $(DEVEL)/SDKs/iPhoneOS3.0.sdk/usr/include/c++/4.2.1

SYSROOT = $(DEVEL)/SDKs/iPhoneSimulator3.0.sdk

CC = $(DEVEL)/usr/bin/gcc-4.2
CXX = $(DEVEL)/usr/bin/g++-4.2
AR = $(DEVEL)/usr/bin/ar
CXXFLAGS = -arch $(ARCH) -isysroot $(SYSROOT) -mmacosx-version-min=10.5 -gdwarf-2 \
	-I$(HOME)/local/include -I/usr/include/malloc \
	-I$(CXXINCLUDE)
LDFLAGS = -g -arch $(ARCH) -L$(HOME)/local/lib \
	-isysroot $(SYSROOT) \
	-mmacosx-version-min=10.5 -framework Foundation

LUA_SRCDIR = lua-5.1.4/src
LUA_CFLAGS = -arch $(ARCH) -isysroot $(SYSROOT) -mmacosx-version-min=10.5 -gdwarf-2 \
	 -I$(LUA_SRCDIR) -DLUA_USE_LINUX
LUA_OBJS = $(patsubst $(LUA_SRCDIR)/%.c,lua_%.o,$(wildcard $(LUA_SRCDIR)/*.c))
LUALIB_OBJS = $(patsubst lua_lua%.o,,$(LUA_OBJS))

# all: suftest sufarr_i386.a

sufarr_i386.a: sufarr.o sufarr_wrap.o $(LUALIB_OBJS)
	$(AR) cru $@ $^

suftest: sufarr.o suftest.o sufarr_wrap.o $(LUALIB_OBJS)
	$(CXX) -o $@ $^ $(LDFLAGS)

sufarr_wrap.cpp: sufarr.i
	swig -o $@ -c++ -lua $?

lua_%.o: $(LUA_SRCDIR)/%.c
	$(CC) $(LUA_CFLAGS) -c -o $@ $?

%.o: %.cpp
	$(CXX) -g -c -o $@ $(CXXFLAGS) $?

clean:
	rm -f suftest *.o *_wrap.cpp *.a *~

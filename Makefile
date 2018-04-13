ifneq ($(TARGET_SYS), )
	OS:=$(TARGET_SYS)
else
	OS:=$(shell uname -s)
endif

CMAKE_FLAGS+= -H. -B${OS} 
ifeq ($(OS),Linux)
	ifndef NPROCS
		NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)
	endif
	ifdef BUILDTYPE
		BUILDTYPE := Release
	endif
	ifndef GENERATOR
		GENERATOR :="Unix Makefiles"
	endif
endif
ifeq ($(OS),Darwin)
	ifndef NPROCS
		NPROCS:=$(shell sysctl hw.ncpu | awk '{print $$2}')
	endif
	ifdef BUILDTYPE
		BUILDTYPE: = Release
	endif
	ifndef GENERATOR
		GENERATOR:="Unix Makefiles"
	endif
endif
ifeq ($(OS),MINGW32_NT-10.0)
	ifndef NPROCS
		NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)
	endif
	ifdef BUILDTYPE
		BUILDTYPE := Release
	endif
	ifndef GENERATOR
		GENERATOR :="Unix Makefiles"
	endif
endif
ifeq ($(OS),MINGW64_NT-10.0)
	ifndef NPROCS
		NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)
	endif
	ifdef BUILDTYPE
		BUILDTYPE := Release
	endif
	ifndef GENERATOR
		GENERATOR :="Unix Makefiles"
	endif
endif
ifeq ($(OS),Windows)
	ifndef NPROCS
		NPROCS:=$(shell sysctl hw.ncpu | awk '{print $$2}')
	endif
	ifndef GENERATOR
		GENERATOR:="Unix Makefiles"
	endif
	ifndef BUILDTYPE
		BUILDTYPE:=RELWITHDEBINFO
	endif
endif
ifeq ($(OS),Android)
	ifndef GENERATOR
		GENERATOR:="Unix Makefiles"
	endif
	ifndef BUILDTYPE
		BUILDTYPE:=RELWITHDEBINFO
	endif
	
	CMAKE_EXTRA_OPTIONS+=-DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION=19 \
	  -DCMAKE_ANDROID_ARCH_ABI=armeabi -DCMAKE_ANDROID_NDK=${ANDROID_NDK} \
	  -DCMAKE_MAKE_PROGRAM=${MAKE} \
	  -DHOST_COMPILER=gcc -DHOST_LINKER=ld
endif
ifeq ($(OS),iOS)
	ifndef GENERATOR
		GENERATOR:="Unix Makefiles"
	endif
	ifndef BUILDTYPE
		BUILDTYPE:=Release
	endif

ifdef NO_LUAJIT
	CMAKE_EXTRA_OPTIONS+=-DCMAKE_TOOLCHAIN_FILE=etc/ios.toolchain.cmake -DIOS_PLATFORM=OS
else
	CMAKE_EXTRA_OPTIONS+=-DCMAKE_TOOLCHAIN_FILE=etc/ios.toolchain.cmake -DIOS_PLATFORM=OS \
		-DIOS_ARCH="armv7;armv7s" -DASM_FLAGS="-arch armv7 -arch armv7s -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS11.3.sdk"
endif
endif

ifdef GENERATOR
	CMAKE_FLAGS+= -G${GENERATOR}
endif

ifdef BUILDTYPE
	CMAKE_FLAGS+= -DCMAKE_BUILD_TYPE=${BUILDTYPE}
endif

ifdef WITHOUT_AMALG
	CMAKE_FLAGS+= -DWITH_AMALG=OFF
endif

#~ ifdef NPROCS
	#~ MAKE_EXTRA_OPTIONS+= -j${NPROCS}
#~ endif

ifdef NO_LUAJIT
	CMAKE_EXTRA_OPTIONS+= -DWITH_LUA_ENGINE=Lua
endif

##############################################################################
all: build
	${MAKE} -C ${OS} ${MAKE_EXTRA_OPTIONS}

build:	$(OS)
	echo build for $(OS) $(CMAKE_EXTRA_OPTIONS)
	
Linux:
	cmake $(CMAKE_FLAGS) $(CMAKE_EXTRA_OPTIONS)

MINGW64_NT-10.0:
	cmake $(CMAKE_FLAGS) $(CMAKE_EXTRA_OPTIONS)
MINGW32_NT-10.0:
	cmake -trace $(CMAKE_FLAGS) $(CMAKE_EXTRA_OPTIONS)
Android:
	cmake $(CMAKE_FLAGS) $(CMAKE_EXTRA_OPTIONS)
Darwin:
	cmake $(CMAKE_FLAGS) $(CMAKE_EXTRA_OPTIONS)
iOS:
	cmake $(CMAKE_FLAGS) $(CMAKE_EXTRA_OPTIONS)

##############################################################################
clean:
	rm -rf ${OS}
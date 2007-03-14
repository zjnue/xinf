# project name
#PROJECT:=cptr

#
# xinf libs Makefile include for (cross-)compiling on linux
# the default target ("Linux" .ndll) should work on any gnu system
# cross-compilation depends on specific setup
# (osx environment in /opt/osx and gentoo crossdev mingw32)
#


# platform default, set this to "Mac" or "Windows" (from the environment) for cross-compilation
NEKO_PLATFORM?=Linux



API_PATH:=api
BIN_PATH:=bin
SRC_PATHS:=src src/$(NEKO_PLATFORM)
NDLL:=$(BIN_PATH)/$(NEKO_PLATFORM)/$(PROJECT).ndll

TARGETS:=$(NDLL)

PROJECT_CFLAGS+=$(foreach SRC_PATH, $(SRC_PATHS), -I$(SRC_PATH))
C_SRCS:=$(foreach SRC_PATH, $(SRC_PATHS), $(wildcard $(SRC_PATH)/*.c))
C_HEADERS:=$(foreach SRC_PATH, $(SRC_PATHS), $(wildcard $(SRC_PATH)/*.h))

# c sources are generated and compiled into the ndll
BINDING_C_SRCS:=$(foreach CLASS, $(BINDING_CLASSES), bind_$(CLASS).c)
C_SRCS+=$(BINDING_C_SRCS)

ifdef BINDING_CLASSES
	# add the implementation neko module to TARGETS
	TARGETS+=$(BIN_PATH)/$(PROJECT).n
endif


####################################################
# setup cross-compilation (or not)

ifeq ($(NEKO_PLATFORM),Mac)
		PATH:=$(PATH):/opt/osx/bin
		OSX_SDK:=/opt/osx/MacOSX10.4u.sdk/
		NEKO_CFLAGS:=-I/opt/osx/manual/include -DNEKO_OSX
		NEKO_LIBS:=-dynamiclib -L/opt/osx/manual/lib -lneko
		PLATFORM_CFLAGS:=-I/opt/osx/powerpc-apple-darwin/include 
		PLATFORM_CFLAGS+=-isysroot $(OSX_SDK) -Wl,-syslibroot,$(OSX_SDK)

default: $(TARGETS)

$(NDLL): $(NDLL).x86 $(NDLL).ppc
	i686-apple-darwin-lipo -create -output $@ -arch i386 $(NDLL).x86 -arch ppc $(NDLL).ppc

$(NDLL).x86: $(C_SRCS) $(C_HEADERS)
	i686-apple-darwin-gcc -o $@ $(C_SRCS) $(OSX_X86_CFLAGS) $(ALL_FLAGS)

$(NDLL).ppc: $(C_SRCS) $(C_HEADERS)
	powerpc-apple-darwin-gcc -o $@ $(C_SRCS) $(OSX_PPC_CFLAGS) $(ALL_FLAGS)

else
	ifeq ($(NEKO_PLATFORM),Windows)
		CC:=mingw32-gcc
		NEKO_CFLAGS:=-I/opt/mingw/include -DNEKO_WIN
		NEKO_LIBS:=-shared -L/opt/mingw/lib -lneko
	else
		CC:=gcc
		NEKO_CFLAGS:=-fPIC -shared -DNEKO_LINUX
		NEKO_LIBS:=-L/usr/lib -lneko -lz  -ldl
	endif

default: $(TARGETS)

$(NDLL): $(C_SRCS) $(C_HEADERS)
	$(CC) -o $@ $(C_SRCS) $(ALL_FLAGS)

endif




ALL_FLAGS=$(NEKO_CFLAGS) $(NEKO_LIBS) $(PLATFORM_CFLAGS) $(PLATFORM_LIBS) $(PROJECT_CFLAGS) $(PROJECT_LIBS)



####################################################
# nekobind binding generation

# rule to generate a c binding class with nekobind
bind_%.c : api/$(XINF_PKG_PATH)/%.hx $(PROJECT).xml
	nekobind -c $(PROJECT).xml $(XINF_PKG).$* > $@

# rule to generate a haxe implementation class with nekobind
%__impl.hx : api/$(XINF_PKG_PATH)/%.hx $(PROJECT).xml
	nekobind -i $(PROJECT).xml $(XINF_PKG).$* > $@


# the interface is defined in $(API_PATH)/$(XINF_PKG_PATH)/*.hx
BINDING_HX:=$(foreach CLASS, $(BINDING_CLASSES), $(API_PATH)/$(XINF_PKG_PATH)/$(CLASS).hx)

# we use haxe to generate a type .xml
$(PROJECT).xml $(PROJECT)-tmp.n: $(BINDING_HX)
	haxe $(HAXEFLAGS) -neko $(PROJECT)-tmp.n -xml $@ -cp $(API_PATH) $(foreach CLASS, $(BINDING_CLASSES), $(XINF_PKG).$(CLASS))


# haxe "implementation classes" (loading the neko module and implement the defined interface)
BINDING_HX_IMPL:=$(foreach CLASS, $(BINDING_CLASSES), $(CLASS)__impl.hx)


# the neko implementation module
$(BIN_PATH)/$(PROJECT).n: $(BINDING_HX_IMPL)
	haxe $(HAXEFLAGS) -cp ../api -neko $@ $(BINDING_HX_IMPL)





####################################################
# meta-targets (not dependant on $(NEKO_PLATFORM)

all:
	NEKO_PLATFORM=Linux make
	NEKO_PLATFORM=Mac make
	NEKO_PLATFORM=Windows make
	
clean:
	-@rm $(BIN_PATH)/Mac/*.ndll $(BIN_PATH)/Windows/*.ndll $(BIN_PATH)/Linux/*.ndll
	-@rm $(PROJECT)-tmp.n $(PROJECT).xml $(foreach CLASS,$(BINDING_CLASSES),bind_$(CLASS).c $(CLASS)__impl.hx)

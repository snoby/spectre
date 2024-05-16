# Compiler
CC = gcc 
CXX = g++
ISPC = ispc

# Compiler flags
CFLAGS = -static -O0 -pthread -m64 -march=znver2  -D__AVX2__ -D__x86_64__ -Wall -O2 -I ./libkeccak -I ./ -I ./astrobwtv3 -I ./include
CXXFLAGS = -Wall -O0 $(CFLAGS) -std=c++20 -Wfatal-errors
ISPCFLAGS =  --target=avx2 -I ./include -I /usr/include

# Source files
C_SRCS = cshake.c
CPP_SRCS = spectrex.cpp
ASTROBWT_CPP_SRCS = $(wildcard astrobwtv3/*.cpp)
ASTROBWT_C_SRCS = $(wildcard astrobwtv3/*.c)
KECCAK_C_SRCS = $(wildcard libkeccak/*.c)
ISPC_SRCS = $(wildcard src/*.ispc)


# Object files
C_OBJS = $(C_SRCS:.c=.o)
CXX_OBJS = $(CPP_SRCS:.cpp=.o)
ISPC_OBJS = $(ISPC_SRCS:.ispc=.o)
ASTROBWT_CPP_OBJS = $(ASTROBWT_CPP_SRCS:.cpp=.o)
ASTROBWT_C_OBJS = $(ASTROBWT_C_SRCS:.c=.o)
KECCAK_C_OBJS = $(KECCAK_C_SRCS:.c=.o)
ISPC_OBJS = $(ISPC_SRCS:.ispc=.o)
ISPC_HEADER_OBJS = $(ISPC_SRCS:.ispc=_ispc.h)


# Library name
LIBRARY = libspectre.a
EXECUTABLE = spectre

# Targets
all: $(LIBRARY) $(EXECUTABLE)

$(LIBRARY): $(C_OBJS) $(CXX_OBJS) $(ISPC_OBJS) $(ASTROBWT_CPP_OBJS) $(ASTROBWT_C_OBJS) $(KECCAK_C_OBJS)
	echo "Linking $@"
	ar rcs $@ $(C_OBJS) $(CXX_OBJS) $(ISPC_OBJS) $(ASTROBWT_CPP_OBJS) $(ASTROBWT_C_OBJS) $(KECCAK_C_OBJS)


$(EXECUTABLE): main.o $(LIBRARY)
	$(CXX) -o $@ main.o -L. -lspectre -lpthread -lm  -lssl -lcrypto

%.o: %.ispc
	$(ISPC) $(ISPCFLAGS) -o $@ -h $(<:.ispc=_ispc.h) $<

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o: %.ispc
	$(ISPC) $(ISPCFLAGS) -o $@ $<

%.o: astrobwtv3/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o: astrobwtv3/%.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: libkeccak/%.c
	$(CC) $(CFLAGS) -c $< -o $@
clean:
	rm -f $(C_OBJS) $(CXX_OBJS) $(ISPC_OBJS) $(ASTROBWT_CPP_OBJS) $(ASTROBWT_C_OBJS)$(KECCAK_C_OBJS) $(LIBRARY) $(EXECUTABLE) main.o


CXXFLAGS = -I$(HOME)/local/include -I/usr/include/malloc
LDFLAGS = -llua -L$(HOME)/local/lib

all: suftest sufarr_i386.a

sufarr_i386.a: sufarr.o
	$(AR) cru $@ $^

suftest: sufarr.o suftest.o sufarr_wrap.o
	$(CXX) -g -o $@ $^ $(LDFLAGS)

sufarr_wrap.cpp: sufarr.i
	swig -o $@ -c++ -lua $?

%.o: %.cpp
	$(CXX) -g -c -o $@ $(CXXFLAGS) $?

clean:
	rm -f suftest *.o *_wrap.cpp *.a *~

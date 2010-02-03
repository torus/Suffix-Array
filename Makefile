CXXFLAGS = -I$(HOME)/local/include -I/usr/include/malloc
LDFLAGS = -llua -L$(HOME)/local/lib

suftest: sufarr.o suftest.o sufarr_wrap.o
	g++ -g -o $@ $^ $(LDFLAGS)

sufarr_wrap.cpp: sufarr.i
	swig -o $@ -c++ -lua $?

%.o: %.cpp
	g++ -g -c -o $@ $(CXXFLAGS) $?

clean:
	rm -f suftest *.o *_wrap.cpp *~

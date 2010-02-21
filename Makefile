CXXFLAGS = -shared -fPIC -g -I$(HOME)/local/include -I/usr/include/malloc
LDFLAGS = -shared -fPIC -L$(HOME)/local/lib

sufarr.so: sufarr.o sufarr_wrap.o
	$(CXX) -flat_namespace -undefined suppress -o $@ $^ $(LDFLAGS)

sufarr_wrap.cpp: sufarr.i
	swig -o $@ -c++ -lua $?

%.o: %.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $?

clean:
	rm -f suftest *.o *_wrap.cpp *.a *.so *.dylib *~

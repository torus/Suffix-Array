suftest: sufarr.o
	g++ -g -o $@ $? $(LDFLAGS)

%.o: %.cpp
	g++ -g -c -o $@ $(CXXFLAGS) $?

clean:
	rm -f suftest *.o *~

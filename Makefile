suftest: sufarr.o
	g++ -o $@ $? $(LDFLAGS)

%.o: %.cpp
	g++ -c -o $@ $(CXXFLAGS) $?

clean:
	rm -f suftest *.o *~

CXXFLAGS = -shared -fPIC -g -I$(HOME)/local/include -I/usr/include/malloc
LDFLAGS = -shared -fPIC -L$(HOME)/local/lib
ABOUT = xcode/Resources/about.html
MARKDOWN = perl -MText::Markdown -e '$$/=undef;print Text::Markdown->new->markdown(<>)'

all: sufarr.so $(ABOUT)

$(ABOUT): about.md
	$(MARKDOWN) $? > $@

sufarr.so: sufarr.o sufarr_wrap.o
	$(CXX) -flat_namespace -undefined suppress -o $@ $^ $(LDFLAGS)

sufarr_wrap.cpp: sufarr.i
	swig -o $@ -c++ -lua $?

%.o: %.cpp
	$(CXX) -c -o $@ $(CXXFLAGS) $?

clean:
	rm -f suftest *.o *_wrap.cpp *.a *.so *.dylib *~


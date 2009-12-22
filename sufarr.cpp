// -*- c-basic-offset: 4; indent-tabs-mode: nil -*-

#include <set>
#include <algorithm>
#include <iostream>
#include <iterator>
#include <string>
#include <string.h>

struct ltstr
{
    bool operator()(const char* s1, const char* s2) const
    {
        return strcmp(s1, s2) < 0;
    }
};

typedef std::set<const char*, ltstr> SetType;

class SufArr {
public:
    explicit SufArr (const std::string &str) : source (str) {
        int len = source.length ();
        for (int i = 0; i < len; i ++) {
            tree.insert (source.c_str () + i);
        }
    }
    const std::string source;
    SetType tree;
};


int
main ()
{
    std::string src = "abracadabra";
    SufArr arr (src);

    std::copy (arr.tree.begin(), arr.tree.end(), std::ostream_iterator<const char*>(std::cout, "\n"));
}

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

std::ostream&
operator << (std::ostream &os, const SufArr &arr)
{
    const char* src = arr.source.c_str ();
    for (SetType::const_iterator it = arr.tree.begin (); it != arr.tree.end (); it ++) {
        unsigned int v = (*it) - src;
        for (int i = 0; i < 4; i ++) {
            char c = (v >> (3 - i) * 8) & 0xff;
            os << c;
        }
    }
    return os;
}

int
main ()
{
    std::string src = "abracadabra";
    SufArr arr (src);

    // std::copy (arr.tree.begin(), arr.tree.end(), std::ostream_iterator<const char*>(std::cout, "\n"));

    std::cout << arr;
}

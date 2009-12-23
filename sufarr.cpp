// -*- c-basic-offset: 4; indent-tabs-mode: nil -*-

#include <algorithm>
#include <fstream>
#include <iostream>
#include <iterator>
#include <set>
#include <sstream>
#include <string>
#include <vector>

#include <string.h>

struct ltstr
{
    bool operator()(const char* s1, const char* s2) const
    {
        return strcmp(s1, s2) < 0;
    }
};

typedef std::set<const char*, ltstr> SetType;

class Indexer {
public:
    explicit Indexer (const std::string &str) : source (str) {
        int len = source.length ();
        for (int i = 0; i < len; i ++) {
            tree.insert (source.c_str () + i);
        }
    }
    const std::string source;
    SetType tree;
};

std::ostream&
operator << (std::ostream &os, const Indexer &arr)
{
    const char* src = arr.source.c_str ();
    for (SetType::const_iterator it = arr.tree.begin (); it != arr.tree.end (); it ++) {
        size_t v = (*it) - src;
        for (int i = 0; i < 4; i ++) {
            char c = (v >> (3 - i) * 8) & 0xff;
            os << c;
        }
    }
    return os;
}


class Index {
public:
    typedef std::vector<size_t> vec;
    vec index;
};

std::istream&
operator >> (std::istream &is, Index &idx)
{
    do {
        size_t x;
        for (int i = 0; i < 4; i ++) {
            x <<= 8;
            char c;
            is.get (c);
            x += static_cast<unsigned char>(c);
        }
        idx.index.push_back (x);
    } while (is.good ());
    return is;
}

int
main ()
{
    // std::string src = "abracadabra";
    std::stringbuf buf;
    std::ifstream ifs ("sufarr.cpp");
    ifs >> &buf;

    std::string src = buf.str ();
    Indexer arr (src);

    std::ofstream ofs ("index");
    ofs << arr;

    ofs.close ();

    std::ifstream idx_strm ("index");
    Index idx;
    idx_strm >> idx;

    Index::vec::const_iterator it =
        std::lower_bound (idx.index.begin (), idx.index.end (), 10);
    std::cerr << *it;
    std::cerr << src.c_str () + *it;
}

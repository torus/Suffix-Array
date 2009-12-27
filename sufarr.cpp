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
    struct UTF8Filter {
        bool operator () (const char *data) {
            bool dest = (*data & 0x80) == 0 || (*data & 0xC0) == 0xC0;
            if (dest)
                std::cerr << std::hex << (int) (unsigned char)*data << std::endl;
            return dest;
        }
    } filter;

    explicit Indexer (const std::string &str) : source (str) {
        int len = source.length ();
        for (int i = 0; i < len; i ++) {
            const char *data = source.c_str () + i;
            if (filter (data)) {
                std::cerr << " " << data << std::endl;
                tree.insert (data);
            }
        }
    }
    const std::string source;
    SetType tree;
};

std::ostream&
operator << (std::ostream &os, const Indexer &arr)
{
    const char* src = arr.source.c_str ();
    const SetType &t = arr.tree;
    for (SetType::const_iterator it = t.begin (); it != t.end (); it ++) {
        size_t v = (*it) - src;
        for (int i = 0; i < 4; i ++) {
            char c = (v >> (3 - i) * 8) & 0xff;
            os << c;
        }
    }
    return os;
}

struct ltstr_index
{
    explicit ltstr_index (const std::string &src) : source (src) {}

    bool operator()(size_t i1, const char *key) const
    {
        const char* s1 = source.c_str () + i1;
        const char* s2 = key;

        return strcmp(s1, s2) < 0;
    }

    const std::string source;
};

class Index {
public:
    typedef std::vector<size_t> vec;
    vec index;
};

std::istream&
operator >> (std::istream &is, Index &idx)
{
    std::cerr << std::dec;
    while (is.good ()) {
        size_t x = 0;
        for (int i = 0; i < 4; i ++) {
            x <<= 8;
            char c;

            is.get (c);
            if (! is.good ()) break;

            unsigned int uc = static_cast<unsigned int>(c);
            std::cerr << uc;
            x += uc;
        }
        std::cerr << "read: " << x << std::endl;
        idx.index.push_back (x);
    }
    return is;
}

int
main ()
{
    std::string src = "abraアブラcadabraカダブラ";
    // std::stringbuf buf;
    // std::ifstream ifs ("sufarr.cpp");
    // ifs >> &buf;

    // std::string src = buf.str ();
    Indexer arr (src);

    std::ofstream ofs ("index");
    ofs << arr;

    ofs.close ();

    std::ifstream idx_strm ("index");
    Index idx;
    idx_strm >> idx;

    Index::vec::const_iterator it =
        std::lower_bound (idx.index.begin (), idx.index.end (),
                          "ラc", ltstr_index (src));
    if (it != idx.index.end ()) {
        std::cerr << *it;
        std::cerr << (src.c_str () + *it) << std::endl;
    }
}

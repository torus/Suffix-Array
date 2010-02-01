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

#include "sufarr_c_api.h"

struct ltstr
{
    bool operator()(const char* s1, const char* s2) const
    {
        return strcmp(s1, s2) < 0;
    }
};

typedef std::set<const char*, ltstr> SetType;

struct UTF8Filter {
    bool operator () (const char *data) {
        bool dest = (*data & 0x80) == 0 || (*data & 0xC0) == 0xC0;
        // if (dest)
        //     std::cerr << std::hex << (int) (unsigned char)*data << std::endl;
        return dest;
    }
};

class Indexer {
public:
    explicit Indexer (const std::string &str) : source (str) {
        int len = source.length ();
        for (int i = 0; i < len; i ++) {
            const char *data = source.c_str () + i;
            if (filter (data)) {
                // std::cerr << " " << data << std::endl;
                tree.insert (data);
            }
        }
    }
    const std::string source;
    SetType tree;
    UTF8Filter filter;
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
        std::cerr << __LINE__ << " " << i1 << std::endl;
        const char* s1 = source.c_str () + i1;
        const char* s2 = key;

        return strcmp(s1, s2) < 0;
    }

    const std::string source;
};

struct gtstr_index
{
    explicit gtstr_index (const std::string &src) : source (src) {}

    bool operator()(const char *key, size_t i1) const
    {
        std::cerr << __LINE__ << " " << i1 << std::endl;
        const char* s1 = source.c_str () + i1;
        const char* s2 = key;

        return strcmp(s2, s1) < 0;
    }

    const std::string source;
};

class Index {
public:
    typedef std::vector<size_t> vec;
    std::string src;
    vec index;
};

std::istream&
operator >> (std::istream &is, Index &idx)
{
    // std::cerr << std::dec;
    while (is.good ()) {
        size_t x = 0;
        for (int i = 0; i < 4; i ++) {
            x <<= 8;
            char c;

            is.get (c);
            if (! is.good ()) break;

            unsigned int uc = static_cast<unsigned char>(c);
            // std::cerr << uc;
            x += uc;
        }
        // std::cerr << "read: " << x << std::endl;
        idx.index.push_back (x);
    }
    return is;
}

void*
create_indexer (const char *path)
{
    std::stringbuf buf;
    std::ifstream ifs (path);
    ifs >> &buf;

    std::string src = buf.str ();
    try {
        Indexer *arr = new Indexer (src);

        return static_cast<void*>(arr);
    } catch (...) {
        return NULL;
    }
}

void
save_index (void *indexer, const char *path)
{
    std::ofstream ofs (path);
    ofs << *static_cast<Indexer*>(indexer);
    std::cerr << __LINE__ << std::endl;

    ofs.close ();
}

void *
load_index (const char *path, const char *src_path)
{
    std::ifstream idx_strm (path);
    Index *idx = new Index;
    idx_strm >> *idx;
    std::cerr << __LINE__ << std::endl;

    std::ifstream src_strm (src_path);
    std::stringbuf buf;

    src_strm >> &buf;

    idx->src = buf.str ();

    std::cerr << "total len: " << (idx->src.length ()) << std::endl;

    return static_cast<void*>(idx);
}

const char *
get_source_text (void *idx_p)
{
    Index &idx = *static_cast<Index*>(idx_p);
    return idx.src.c_str ();
}

int
get_position (void *idx_p, int n)
{
    Index &idx = *static_cast<Index*>(idx_p);
    Index::vec::const_iterator it = idx.index.begin () + n;

    return *it;
}

int
search_lower_bound (void *idx_p, const char *pat)
{
    Index &idx = *static_cast<Index*>(idx_p);
    std::string src (idx.src);

    Index::vec::const_iterator it_l =
        std::lower_bound (idx.index.begin (), idx.index.end (),
                          pat, ltstr_index (src));

    return it_l - idx.index.begin ();
}

int
search_upper_bound (void *idx_p, const char *pat)
{
    Index &idx = *static_cast<Index*>(idx_p);
    std::string src (idx.src);

    std::string pat2 (pat);
    pat2.append ("\xff");

    Index::vec::const_iterator it_2 =
        std::upper_bound (idx.index.begin (), idx.index.end (),
                          pat2.c_str (), gtstr_index (src));

    return it_2 - idx.index.begin ();
}

int
main ()
{
    void *indexer = create_indexer ("sufarr.cpp");
    save_index (indexer, "sufarr.idx");

    void *index = load_index ("sufarr.idx", "sufarr.cpp");

    int lb = search_lower_bound (index, "lower");
    int ub = search_upper_bound (index, "lower");

    std::cerr << "found: " << lb << " " << ub << std::endl;
    for (int i = lb;i != ub; i ++) {
        std::cerr << "- "
                  << std::string (get_source_text (index) + get_position (index, i), 50)
                  << std::endl;
    }
}

int
main_oo ()
{
    std::string src = "abraアブラcadabraカダブラ";
    // std::stringbuf buf;
    // std::ifstream ifs ("sufarr.cpp");
    // ifs >> &buf;

    // std::string src = buf.str ();
    Indexer arr (src);

    std::cerr << __LINE__ << std::endl;

    std::ofstream ofs ("index");
    ofs << arr;
    std::cerr << __LINE__ << std::endl;

    ofs.close ();

    std::ifstream idx_strm ("index");
    Index idx;
    idx_strm >> idx;
    std::cerr << __LINE__ << std::endl;

    Index::vec::const_iterator it =
        std::lower_bound (idx.index.begin (), idx.index.end (),
                          "ra", ltstr_index (src));

    std::cerr << __LINE__ << std::endl;

    if (it != idx.index.end ()) {
        Index::vec::const_iterator it2 =
            std::upper_bound (idx.index.begin (), idx.index.end (),
                              "ra\xff", gtstr_index (src));

        std::cerr << "range: " << (it - idx.index.begin ()) << " - "
                  << (it2 - idx.index.begin ()) << std::endl;

        while (it != idx.index.end () && it != it2) {
            std::cerr << *it << ":\t";
            std::cerr << src.c_str () + *it << std::endl;

            it ++;
        }
    }
}

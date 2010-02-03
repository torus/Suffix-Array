// -*- mode: c++; c-basic-offset: 4; indent-tabs-mode: nil -*-

#include <iostream>

#include <lua.hpp>

#include "sufarr_c_api.h"

extern "C" int luaopen_sufarr (lua_State *L);

int
main (int argc, char **argv)
{
    if (argc < 2) exit (1);

    lua_State *L = lua_open ();
    luaL_openlibs (L);
    luaopen_sufarr (L);

    std::cerr << argv[1] << std::endl;

    if (! luaL_loadfile (L, argv[1])) {
        lua_call (L, 0, 0);
    } else {
        std::cerr << "error" << std::endl;
    }

    lua_close (L);

    return 0;
}
// int
// main ()
// {
//     void *indexer = create_indexer ("sufarr.cpp");
//     save_index (indexer, "sufarr.idx");

//     void *index = load_index ("sufarr.idx", "sufarr.cpp");

//     int lb = search_lower_bound (index, "lower");
//     int ub = search_upper_bound (index, "lower");

//     std::cerr << "found: " << lb << " " << ub << std::endl;
//     for (int i = lb;i != ub; i ++) {
//         std::cerr << "- "
//                   << std::string (get_source_text (index) + get_position (index, i), 50)
//                   << std::endl;
//     }
// }

%module sufarr

%{
#include "sufarr_c_api.h"
%}

%include "sufarr_c_api.h"

%native(pack_pos) int packPos (lua_State *L);

%{
  int packPos (lua_State *L)
  {
    int p = lua_tointeger (L, 1);
    lua_pop (L, 1);

    char str[4];
    for (int i = 0; i < 4; i ++) {
      str[i] = p >> ((3 - i) * 8) & 0xff;
    }
    lua_pushlstring (L, str, 4);
    return 1;
  }
%}

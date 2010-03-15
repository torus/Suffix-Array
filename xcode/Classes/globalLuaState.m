/*
 *  globalLuaState.c
 *  Bible Search
 *
 *  Created by Toru Hisai on 10/03/13.
 *  Copyright 2010 Kronecker's Delta. All rights reserved.
 *
 */

#include "globalLuaState.h"

#import "lualib.h"
#import "lauxlib.h"

lua_State *L = NULL;

extern int luaopen_sufarr(lua_State* L); // declare the wrapped module

int exec_lua (lua_State *L, NSString *luastat)
{
    //    NSLog(@"statement: %@", luastat);
    if (!L) {
        initialize_lua();
    }
    const char *str = [luastat cStringUsingEncoding:NSASCIIStringEncoding];
    int top = lua_gettop(L);
    int res2 = (luaL_loadstring(L, str) || lua_pcall(L, 0, LUA_MULTRET, 0));

    //    NSLog(@"lua: returned %d, top: %d -> %d", res2, top, lua_gettop(L));
    if (res2) {
        const char* err = lua_tostring(L, -1);
        NSLog(@"error: %s", err);
        return -1;
    } else {
        return lua_gettop(L) - top;
    }
}

void initialize_lua ()
{
    L = lua_open ();
    luaL_openlibs (L);
    luaopen_sufarr (L);    

    NSString *scriptPath = [[[NSBundle mainBundle]
                   pathForResource:@"indexer" ofType:@"lua"] retain];

    int res = luaL_dofile(L, [scriptPath cStringUsingEncoding:NSASCIIStringEncoding]);
    [scriptPath release];
    NSLog(@"lua: returned %d", res);
    if (res) {
        const char* err = lua_tostring(L, -1);
        NSLog(@"error: %s", err);
    }
}

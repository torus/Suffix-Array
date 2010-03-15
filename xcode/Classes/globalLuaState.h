/*
 *  globalLuaState.h
 *  Bible Search
 *
 *  Created by Toru Hisai on 10/03/13.
 *  Copyright 2010 Kronecker's Delta. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "lua.h"

lua_State *L;

void initialize_lua ();
int exec_lua (lua_State *L, NSString *luastat);

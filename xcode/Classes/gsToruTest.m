//
//  gsToruTest.m
//  Chapter3 Framework
//
//  Created by Toru Hisai on 10/02/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ResourceManager.h"
#import "gsToruTest.h"
#import "gsMainMenu.h"

#import "SuffixArray/lua.h"
#import "SuffixArray/lualib.h"
#import "SuffixArray/lauxlib.h"

extern int luaopen_sufarr(lua_State* L); // declare the wrapped module

@implementation gsToruTest

-(gsToruTest*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager 
{
	if(self = [super initWithFrame:frame andManager:pManager]) {
		//load the storagetest.xib file here.
		//this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"torutest" owner:self options:nil];
		//add subview as... a subview.
		//this will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	//load the last saved state of the toggle switch.
	[self runTests];

	return self;
}

-(void) runTests {
    NSLog(@"runTests!");

    lua_State *L = lua_open ();
    luaL_openlibs (L);
    luaopen_sufarr (L);

    NSString *dir = [[NSBundle mainBundle] bundlePath];
    NSString *script_path = [[NSBundle mainBundle]
                             pathForResource:@"test" ofType:@"lua"];

    int res = luaL_dofile(L, [script_path cStringUsingEncoding:NSASCIIStringEncoding]);
    NSLog(@"lua: returned %d", res);
    if (res) {
        const char* err = lua_tostring(L, -1);
        NSLog(@"error: %s", err);
    }

    NSString *luastat = [NSString stringWithFormat:@"dotest(\"%@\")", dir];
    NSLog(@"statement: %@", luastat);
    int res2 = luaL_dostring(L, [luastat cStringUsingEncoding:NSASCIIStringEncoding]);
    NSLog(@"lua: returned %d", res2);
    if (res2) {
        const char* err = lua_tostring(L, -1);
        NSLog(@"error: %s", err);
    }
}
@end

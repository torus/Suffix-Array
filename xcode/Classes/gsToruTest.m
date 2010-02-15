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

static int exec_lua (lua_State *L, NSString *luastat)
{
//    NSString *luastat = [NSString stringWithFormat:@"mkindex(\"%@\",\"%@\")", dir, script_path];
    NSLog(@"statement: %@", luastat);
//    int res2 = luaL_dostring(L, [luastat cStringUsingEncoding:NSASCIIStringEncoding]);
    const char *str = [luastat cStringUsingEncoding:NSASCIIStringEncoding];
    int top = lua_gettop(L);
    int res2 = (luaL_loadstring(L, str) || lua_pcall(L, 0, LUA_MULTRET, 0));

    NSLog(@"lua: returned %d, top: %d -> %d", res2, top, lua_gettop(L));
    if (res2) {
        const char* err = lua_tostring(L, -1);
        NSLog(@"error: %s", err);
        return 0;
    } else {
        return lua_gettop(L) - top;
    }
}

-(void) runTests {
    NSLog(@"runTests!");

    lua_State *L = lua_open ();
    luaL_openlibs (L);
    luaopen_sufarr (L);

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dir = [paths objectAtIndex:0];

    NSString *script_path = [[NSBundle mainBundle]
                             pathForResource:@"test" ofType:@"lua"];

    int res = luaL_dofile(L, [script_path cStringUsingEncoding:NSASCIIStringEncoding]);
    NSLog(@"lua: returned %d", res);
    if (res) {
        const char* err = lua_tostring(L, -1);
        NSLog(@"error: %s", err);
    }

    int r1 = exec_lua(L, [NSString stringWithFormat:@"return mkindex(\"%@\",\"%@\")", dir, script_path]);
    int r2 = exec_lua(L, [NSString stringWithFormat:@"return search(\"%@\",\"%@\",\"%s\")", dir, script_path, "local"]);

    NSLog(@"%d, %d", r1, r2);
    ///////////
//    arryAppleProducts = [[NSArray alloc] initWithObjects:@"iPhone", @"iPod", @"MacBook", @"MacBook Pro", nil];
	arryAdobeSoftwares = [[NSArray alloc] initWithObjects:@"Flex", @"AIR", @"Flash", @"Photoshop", @"Illustrator", nil];  
    arryAppleProducts = [[NSMutableArray alloc] init];

    for (int i = 0; i < r2; i ++) {
        NSString *item = [[NSString alloc] initWithUTF8String: lua_tostring(L, r2 - i)];
//        NSLog(@"item %@", item);
        [arryAppleProducts addObject: item];
    }
}



////////////

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSLog(@"%s", __FUNCTION__);
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);
	if (section == 0)
		return [arryAppleProducts count];
	else
		return [arryAdobeSoftwares count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
	static NSString *CellIndentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIndentifier] autorelease];
	}
	if (indexPath.section == 0)
		cell.text = [arryAppleProducts objectAtIndex:indexPath.row];
	else
		cell.text = [arryAdobeSoftwares objectAtIndex:indexPath.row];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);
	if (section == 0)
		return @"Apple Products";
	else
		return @"Adobe Softwares";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __FUNCTION__);
}


@end

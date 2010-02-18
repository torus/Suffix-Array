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
    NSLog(@"statement: %@", luastat);

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

static void search_and_update_table (lua_State *L, NSMutableArray *arry,
                                     NSString *workDir, NSString *scriptPath, NSString *word)
{
    NSLog(@"%s: word = %@", __FUNCTION__, word);
    [arry removeAllObjects];
    NSLog(@"%s: removed", __FUNCTION__);
    int r2 = exec_lua(L, [NSString stringWithFormat:@"return search(\"%@\",\"%@\",\"%@\")", workDir, scriptPath, word]);
    NSLog(@"%s: r2 = %d", __FUNCTION__, r2);
    for (int i = 0; i < r2; i ++) {
        NSString *item = [[NSString alloc] initWithUTF8String: lua_tostring(L, r2 - i)];
        [arry addObject: item];
    }
    lua_pop(L, r2);
}

-(void) runTests {
    NSLog(@"runTests!");

    L = lua_open ();
    luaL_openlibs (L);
    luaopen_sufarr (L);

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    workDir = [[paths objectAtIndex:0] retain];

    scriptPath = [[[NSBundle mainBundle]
                            pathForResource:@"test" ofType:@"lua"] retain];

    int res = luaL_dofile(L, [scriptPath cStringUsingEncoding:NSASCIIStringEncoding]);
    NSLog(@"lua: returned %d", res);
    if (res) {
        const char* err = lua_tostring(L, -1);
        NSLog(@"error: %s", err);
    }

    exec_lua(L, [NSString stringWithFormat:@"return mkindex(\"%@\",\"%@\")", workDir, scriptPath]);

    ///////////
    searchResultsArray = [[NSMutableArray alloc] init];
    
    [searchbar becomeFirstResponder];
}


////////////

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSLog(@"%s", __FUNCTION__);
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);
	NSAssert (section == 0, @"section");
	return [searchResultsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
	static NSString *CellIndentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIndentifier] autorelease];
	}
	if (indexPath.section == 0) {
		cell.textLabel.text = [searchResultsArray objectAtIndex:indexPath.row];
    }
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section {
	return @"Search Results";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __FUNCTION__);
}

- (void) searchAndUpdate: (NSString*) searchText {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", self);
    NSLog(@"%@", workDir);

    search_and_update_table (L, searchResultsArray, workDir, scriptPath, searchText);    
    [tblview reloadData];
}


#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"search: %@", searchText);
    [self searchAndUpdate: searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"search button clicked");
    [searchBar resignFirstResponder];
}

@end

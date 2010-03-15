//
//  gsToruTest.m
//  Chapter3 Framework
//
//  Created by Toru Hisai on 10/02/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ResourceManager.h"
#import "gsSearchScreen.h"
#import "gsTextScreen.h"
#import "gsMainMenu.h"
#import "globalLuaState.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"


@implementation gsSearchScreen

-(gsSearchScreen*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager 
{
	if(self = [super initWithFrame:frame andManager:pManager]) {
		//load the storagetest.xib file here.
		//this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"SearchScreen" owner:self options:nil];
		//add subview as... a subview.
		//this will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	//load the last saved state of the toggle switch.
	[self runTests];

	return self;
}

static void search_and_update_table (lua_State *L, NSMutableArray *arry,
                                     NSString *idxPath, NSString *docPath, NSString *word)
{
//    NSLog(@"%s: word = %@", __FUNCTION__, word);
    [arry removeAllObjects];
//    NSLog(@"%s: removed", __FUNCTION__);
    int r2 = exec_lua(L, [NSString stringWithFormat:@"return search_on_file(\"%@\",\"%@\",\"%@\")", idxPath, docPath, word]);
//    int r2 = exec_lua(L, [NSString stringWithFormat:@"return search(\"%@\",\"%@\")", docPath, word]);
//    NSLog(@"%s: r2 = %d", __FUNCTION__, r2);
    for (int i = 0; i < r2; i ++) {
        NSString *item = [[NSString alloc] initWithUTF8String: lua_tostring(L, r2 - i)];
        [arry insertObject:item atIndex:0];
    }
    lua_pop(L, r2);
}

-(void) runTests {
    NSLog(@"runTests!");

//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    workDir = [[paths objectAtIndex:0] retain];
    workDir = [[[NSBundle mainBundle] bundlePath] retain];

    if (!L) {
        initialize_lua();
    }

    docPath = [[workDir stringByAppendingPathComponent:@"kjv.txt"] retain];
    idxPath = [[workDir stringByAppendingPathComponent:@"kjv.idx"] retain];

//    exec_lua(L, [NSString stringWithFormat:@"mkindex(\"%@\",\"%@\")", idxfile, docPath]);
//    exec_lua(L, [NSString stringWithFormat:@"loadindex(\"%@\",\"%@\")", idxfile, docPath]);

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
    NSUInteger len = [indexPath length];
    NSUInteger index = [indexPath indexAtPosition:len - 1];
    NSLog(@"%s, %d, %d", __FUNCTION__, len, index);
    exec_lua(L, [NSString stringWithFormat:@"select_item(\"%@\", \"%@\", %d)", idxPath, docPath, index]);
    [m_pManager doStateChange:[gsTextScreen class]];
}

- (void) searchAndUpdate: (NSString*) searchText {
/*    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", self);
    NSLog(@"%@", docPath);
    NSLog(@"%@", idxPath);
*/
    search_and_update_table (L, searchResultsArray, idxPath, docPath, searchText);    
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

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
#import "gsAboutScreen.h"
#import "globalLuaState.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"


@implementation gsSearchScreen

@synthesize searchbar;

-(gsSearchScreen*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager 
{
	if(self = [super initWithFrame:frame andManager:pManager]) {
		[[NSBundle mainBundle] loadNibNamed:@"SearchScreen" owner:self options:nil];
		[self addSubview:subview];
	}
	[self searchScreenMain];

	return self;
}

static void search_and_update_table (lua_State *L, NSMutableArray *arry,
                                     NSString *idxPath, NSString *docPath, NSString *word)
{
//    NSLog(@"%s: word = %@", __FUNCTION__, word);
    [arry removeAllObjects];
    int r2 = exec_lua(L, [NSString stringWithFormat:@"return search_on_file(\"%@\",\"%@\",\"%@\")", idxPath, docPath, word]);
    int count = lua_tointeger(L, 1);
    for (int i = 0; i < r2 - 1; i ++) {
        NSString *item = [[NSString alloc] initWithUTF8String: lua_tostring(L, r2 - i)];
        [arry insertObject:item atIndex:0];
    }
    NSLog(@"%s: count: %d", __FUNCTION__, count);
    lua_pop(L, r2);
}

-(void) searchScreenMain {
//    NSLog(@"runTests!");

    workDir = [[[NSBundle mainBundle] bundlePath] retain];

    docPath = [[workDir stringByAppendingPathComponent:@"kjv.txt"] retain];
    idxPath = [[workDir stringByAppendingPathComponent:@"kjv.idx"] retain];
    pidxPath = [[workDir stringByAppendingPathComponent:@"kjv.pidx"] retain];
    
    searchResultsArray = [[NSMutableArray alloc] init];

    if (!L) {
        initialize_lua();
    } else {
        int r1 = exec_lua(L, [NSString stringWithFormat:@"return previous_search_results()"]);
        for (int i = 0; i < r1; i ++) {
            NSString *item = [[NSString alloc] initWithUTF8String: lua_tostring(L, r1 - i)];
            [searchResultsArray insertObject:item atIndex:0];
        }
        lua_pop(L, r1);

        int r2 = exec_lua(L, [NSString stringWithFormat:@"return previous_search_word()"]);
        NSString *word = [[NSString alloc] initWithUTF8String: lua_tostring(L, 1)];
        searchbar.text = word;
        lua_pop(L, r2);
    }

    searchbar.keyboardType = UIKeyboardTypeASCIICapable;
    [searchbar becomeFirstResponder];
}

- (void)dealloc {
    [searchResultsArray release];
    [workDir release];
    [idxPath release];
    [pidxPath release];
    [docPath release];
    [searchbar release];
    
    [super dealloc];
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
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
		cell.textLabel.text = [searchResultsArray objectAtIndex:indexPath.row];
    }
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section {
//    NSLog(@"%s", __FUNCTION__);

    int r = exec_lua(L, [NSString stringWithFormat:@"return previous_result_count()"]);
    NSAssert(r == 1, @"previous_result_count");
    int count = lua_tointeger(L, 1);
    lua_pop(L, r);

    return [NSString stringWithFormat:@"Search Results (%d)", count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger len = [indexPath length];
    NSUInteger index = [indexPath indexAtPosition:len - 1];
    NSLog(@"%s, %d, %d", __FUNCTION__, len, index);
    exec_lua(L, [NSString stringWithFormat:@"select_item(\"%@\", \"%@\", %d)", pidxPath, docPath, index]);
    [m_pManager doStateChange:[gsTextScreen class]];
}

- (void) searchAndUpdate: (NSString*) searchText {
    search_and_update_table (L, searchResultsArray, idxPath, docPath, searchText);    
    [tblview reloadData];
}

- (IBAction) aboutButtonTapped {
    NSLog(@"%s: tapped!", __FUNCTION__);
    
    [m_pManager doStateChange:[gsAboutScreen class]];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%s", __FUNCTION__);
    gsSearchScreen *scr = (gsSearchScreen *)scrollView.delegate;
    [scr.searchbar resignFirstResponder];
}

#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"search: %@", searchText);
    [self searchAndUpdate: searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"search button clicked");
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end

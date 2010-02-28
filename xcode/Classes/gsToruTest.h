//
//  gsToruTest.h
//  Chapter3 Framework
//
//  Created by Toru Hisai on 10/02/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"
#import "lua.h"

@interface gsToruTest : GameState {
    IBOutlet UIView *subview;
    IBOutlet UITableView *tblview;
    IBOutlet UISearchBar *searchbar;
    NSMutableArray *searchResultsArray;

    lua_State *L;
    NSString *workDir;
    NSString *scriptPath;
    NSString *idxPath;
    NSString *docPath;
}

- (void) runTests;
- (void) searchAndUpdate: (NSString*) searchText;
@end

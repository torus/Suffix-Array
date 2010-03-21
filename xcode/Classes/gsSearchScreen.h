//
//  gsToruTest.h
//  Chapter3 Framework
//
//  Created by Toru Hisai on 10/02/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface gsSearchScreen : GameState {
    IBOutlet UIView *subview;
    IBOutlet UITableView *tblview;
    IBOutlet UISearchBar *searchbar;
    NSMutableArray *searchResultsArray;

    NSString *workDir;
    NSString *idxPath;
    NSString *pidxPath;
    NSString *docPath;
}

- (void) runTests;
- (void) searchAndUpdate: (NSString*) searchText;
@end

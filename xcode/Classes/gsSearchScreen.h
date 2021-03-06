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
    IBOutlet UIBarButtonItem *aboutbtn;
    IBOutlet UISearchBar *searchbar;
    NSMutableArray *searchResultsArray;

    NSString *workDir;
    NSString *idxPath;
    NSString *pidxPath;
    NSString *docPath;
}

- (void) searchScreenMain;
- (void) searchAndUpdate: (NSString*) searchText;
- (IBAction) aboutButtonTapped;

@property (retain, nonatomic) UISearchBar *searchbar;

@end

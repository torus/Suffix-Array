//
//  gsToruTest.h
//  Chapter3 Framework
//
//  Created by Toru Hisai on 10/02/06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface gsToruTest : GameState {
    IBOutlet UIView *subview;
    IBOutlet UITableView *tblview;
    NSMutableArray *arryAppleProducts;
	NSArray *arryAdobeSoftwares;
}

- (void) runTests;
@end

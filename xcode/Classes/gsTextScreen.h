//
//  gsTextScreen.h
//  Bible Search
//
//  Created by Toru Hisai on 10/02/27.
//  Copyright 2010 Kronecker's Delta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"
#import "lua.h"

@interface gsTextScreen : GameState {
    IBOutlet UIView *subview;
    IBOutlet UINavigationBar *navbar;
    IBOutlet UINavigationItem *titleview;
    IBOutlet UITextView *textview;
}

- (IBAction) backToSearch;
@end

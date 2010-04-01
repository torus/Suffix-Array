//
//  gsAboutScreen.h
//  Bible Search
//
//  Created by Toru Hisai on 10/03/28.
//  Copyright 2010 Kronecker's Delta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface gsAboutScreen : GameState {
    IBOutlet UIView *subview;
    IBOutlet UIWebView *webview;
    IBOutlet UINavigationBar *navbar;
    IBOutlet UINavigationItem *navitem;
}

- (IBAction) backButtonTapped;

@end

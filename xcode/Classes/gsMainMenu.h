//
//  gsMainMenu.h
//  Chapter3 Framework
//
//  Created by Joe Hogue and Paul Zirkle
//

#import <Foundation/Foundation.h>

#import "GameState.h"

@interface gsMainMenu : GameState {
	IBOutlet UIView* subview;
}

- (IBAction) doGraphicsTest;
- (IBAction) doSoundTest;
- (IBAction) doStorageTest;

- (IBAction) doSearch;

@end

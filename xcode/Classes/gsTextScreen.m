//
//  gsTextScreen.m
//  Bible Search
//
//  Created by Toru Hisai on 10/02/27.
//  Copyright 2010 Kronecker's Delta. All rights reserved.
//

#import "ResourceManager.h"
#import "gsTextScreen.h"
#import "gsSearchScreen.h"

@implementation gsTextScreen

-(gsTextScreen*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager 
{
	if(self = [super initWithFrame:frame andManager:pManager]) {
		//load the storagetest.xib file here.
		//this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"TextScreen" owner:self options:nil];
		//add subview as... a subview.
		//this will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	//load the last saved state of the toggle switch.
    NSLog(@"%s", __FUNCTION__);
    
    titleview.title = @"hoge";
    titleview.backBarButtonItem.title = @"Back to Search";
    textview.text = @"ananan";

    return self;
}

- (IBAction) backToSearch {
    NSLog(@"backToSearch");
    [m_pManager doStateChange:[gsSearchScreen class]];
}

@end

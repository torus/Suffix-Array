//
//  gsAboutScreen.m
//  Bible Search
//
//  Created by Toru Hisai on 10/03/28.
//  Copyright 2010 Kronecker's Delta. All rights reserved.
//

#import "gsAboutScreen.h"
#import "gsSearchScreen.h"


@implementation gsAboutScreen

-(gsAboutScreen*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager 
{
	if(self = [super initWithFrame:frame andManager:pManager]) {
		//load the storagetest.xib file here.
		//this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"AboutScreen" owner:self options:nil];
		//add subview as... a subview.
		//this will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	//load the last saved state of the toggle switch.
    
    navitem.title = @"About";
    navitem.leftBarButtonItem.title = @"Search";

    NSString *path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
    NSLog(@"%s, path = %@", __FUNCTION__, path);
    
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error: nil];

    [webview loadHTMLString:text baseURL:nil];

    return self;
}

- (IBAction) backButtonTapped {
    NSLog(@"%s: back", __FUNCTION__);
    [m_pManager doStateChange:[gsSearchScreen class]];
}

@end

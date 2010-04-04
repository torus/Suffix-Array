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
#import "globalLuaState.h"

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

    if (!L) {
        initialize_lua();
    }

    int r = exec_lua(L, @"return get_paragraph()");
    NSString *title, *body;
    if (r > 1) {
        title = [[NSString stringWithCString:lua_tostring(L, 1)
                                    encoding:NSUTF8StringEncoding] retain];
        body = [[NSString stringWithCString:lua_tostring(L, 2)
                                    encoding:NSUTF8StringEncoding] retain];
        lua_pop(L, r);
    }

    titleview.title = title;
    titleview.leftBarButtonItem.title = @"Search";

    textview.editable = NO;
    textview.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:24];
    textview.text = body;

    return self;
}

- (IBAction) backToSearch {
    NSLog(@"backToSearch");
    [m_pManager doStateChange:[gsSearchScreen class]];
}

@end

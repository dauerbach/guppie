//
//  SAGUPPopoverView.m
//  guppie
//
//  Created by Dan Auerbach on 11/4/12.
//  Copyright (c) 2012 SoupyApps. All rights reserved.
//

#import "SAGUPPopoverView.h"

@implementation SAGUPPopoverView
@synthesize uploadedURL;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent {

	if ([uploadedURL stringValue]) {

		NSString *URLPart = [[[uploadedURL stringValue] componentsSeparatedByString:@" "] objectAtIndex:0];

		if ([URLPart length] > 0) {
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:URLPart]];
		}

	}
	
}


@end

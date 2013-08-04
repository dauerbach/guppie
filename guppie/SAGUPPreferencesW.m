//
//  SAGUPPreferencesW.m
//  guppie
//
//  Created by Dan Auerbach on 10/10/12.
//  Copyright (c) 2012 SoupyApps. All rights reserved.
//

#import "SAGUPPreferencesW.h"

@implementation SAGUPPreferencesW

-(void)keyDown:(NSEvent *)theEvent {

	
	if (([theEvent modifierFlags] & NSCommandKeyMask) && ([[theEvent charactersIgnoringModifiers] isEqualToString:@"w"])) {
		[self close];
	} else {
		[super keyDown:theEvent];
	}

}

@end

//
//  SAGUPStatusItemView.h
//  guppie
//
//  Created by Dan Auerbach on 10/14/12.
//  Copyright (c) 2012 SoupyApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SAGUPAppDelegate.h"

@interface SAGUPStatusItemView : NSView <NSMenuDelegate> {
	
	BOOL _highlight;
	NSStatusItem* _statusItem;
	NSMenu* _statusMenu;
	
	BOOL _uploadInProgress;

}
- (void)setStatusItem:(NSStatusItem *)statusItem;
- (void)setUploadInProgress:(BOOL)boolval;
- (BOOL)uploadInProgress;
@end

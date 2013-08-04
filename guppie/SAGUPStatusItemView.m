//
//  SAGUPStatusItemView.m
//  guppie
//
//  Created by Dan Auerbach on 10/14/12.
//  Copyright (c) 2012 SoupyApps. All rights reserved.
//

#import "SAGUPStatusItemView.h"

@implementation SAGUPStatusItemView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		//register for drags
		[self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
		_uploadInProgress = TRUE;
	}
	
	return self;
}

- (void)setUploadInProgress:(BOOL)boolval {
	_uploadInProgress = boolval;
}
- (BOOL)uploadInProgress {
	return _uploadInProgress;
}


- (void)drawRect:(NSRect)dirtyRect
{
	//the status item will just be a yellow rectangle
	NSBundle *bundle = [NSBundle mainBundle];
	NSImage* guppieIcon = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"guppieColorIcon" ofType:@"png"]];
	
	if (guppieIcon) {
		[guppieIcon drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
	}
	

//	[[NSColor yellowColor] set];
//	NSRectFill([self bounds]);
}

- (void)setStatusItem:(NSStatusItem *)statusItem {
	_statusItem = statusItem;
}

- (void)setMenu:(NSMenu *)menu {
	_statusMenu = menu;
//	[menu setDelegate:self];
//	[super setMenu:menu];
}

- (void)mouseDown:(NSEvent *)event {
	[_statusItem popUpStatusItemMenu:_statusMenu]; // or another method that returns a menu
}

- (void)menuWillOpen:(NSMenu *)menu {
	_highlight = YES;
	[self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
	_highlight = NO;
	[self setNeedsDisplay:YES];
}

//we want to copy the files
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	if (!_uploadInProgress) {
		return NSDragOperationCopy;
	} else {
		return NSDragOperationNone;
	}
 
}

//perform the drag and log the files that are dropped
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
	
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
		[[NSApp delegate] uploadFile:[files objectAtIndex:0]];
		
		NSLog(@"Files: %@",files);
		
		return YES;
	} else {
		return NO;
	}
}



@end

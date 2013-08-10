//
//  SAGUPAppDelegate.h
//  guppie
//
//  Created by Dan Auerbach on 10/10/12.
//  Copyright (c) 2012 SoupyApps. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

//#import "SBJson.h"
#import "DDHotKeyCenter.h"
#import "SAGUPPreferencesWC.h"

@class SAGUPStatusItemView;

@interface SAGUPAppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDataDelegate, NSUserNotificationCenterDelegate> {
	
	NSStatusItem 			*_statusItem;
	SAGUPStatusItemView 	*_statusItemView;
	NSImage 					*_statusImage;
	NSMutableData 			*responseData;
	BOOL						_uploadInProgress;
	NSString					*_curFilename;
	NSString 				*_progressMsg;
	NSTimer					*_progressUpdateTimer;
	
	SAGUPPreferencesWC *_prefsWindow;
	
	NSOpenPanel *_panel;
	
	long	_OSVersionMajor, _OSVersionMinor, _OSVersionBugfix;
	
	NSUserNotificationCenter *_unc;

}
@property (weak) IBOutlet NSPopover *URLPopover;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *URLLabel;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *uploadMenuItem;
@property (weak) IBOutlet NSMenuItem *screenCaptureMenuItem;

- (IBAction)screenCapture:(id)sender;

-(IBAction)uploadFiles:(id)sender;
-(IBAction)openPreferences:(id)sender;
-(IBAction)checkForUpdates:(id)sender;
-(IBAction)quit:(id)sender;

-(BOOL)uploadFile:(NSString *)filename;
-(void)setUploadInProgress:(BOOL)boolval;
@end

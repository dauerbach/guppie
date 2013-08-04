//
//  SAGUPAppDelegate.m
//  guppie
//
//  Created by Dan Auerbach on 10/10/12.
//  Copyright (c) 2012 SoupyApps. All rights reserved.
//

#import "SAGUPAppDelegate.h"
#import "SAGUPStatusItemView.h"


void GetSystemVersion( long *major, long *minor, long *bugfix )
{
	// sensible default
	static long mMajor = 10;
	static long mMinor = 8;
	static long mBugfix = 0;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString* versionString = [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"];
		NSArray* versions = [versionString componentsSeparatedByString:@"."];
		check( versions.count >= 2 );
		if ( versions.count >= 1 ) {
			mMajor = [versions[0] integerValue];
		}
		if ( versions.count >= 2 ) {
			mMinor = [versions[1] integerValue];
		}
		if ( versions.count >= 3 ) {
			mBugfix = [versions[2] integerValue];
		}
	});
	
	*major = mMajor;
	*minor = mMinor;
	*bugfix = mBugfix;
}



@implementation SAGUPAppDelegate
@synthesize URLLabel;
@synthesize _statusMenu;
@synthesize uploadMenuItem = _uploadMenuItem;
@synthesize screenCaptureMenuItem = _screenCaptureMenuItem;
@synthesize URLPopover;

- (void)awakeFromNib {
	
	_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	
//	NSBundle *bundle = [NSBundle mainBundle];
//	statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"guppieColorIcon" ofType:@"png"]];
//	[statusItem setImage:statusImage];

	//Use a title instead of images
//	[statusItem setTitle:@"G"];
//	[statusItem setMenu:statusMenu];
	[_statusItem setToolTip:@"Guppie"];
	
	_statusItemView = [[SAGUPStatusItemView alloc] initWithFrame:NSMakeRect(0, 0, 24, 24)];
	[_statusItem setView:_statusItemView];
	
	[_statusItemView setStatusItem:_statusItem];

	[_statusItemView setMenu:_statusMenu];
	[_statusMenu setAutoenablesItems:FALSE];
	
	_prefsWindow = [[SAGUPPreferencesWC alloc] initWithWindowNibName:@"SAGUPPreferences"];
	
	
	NSDictionary *prefsDict = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE], @"isAuthenticatedAccount",
										@"imgurUsername", @"imgurUsername",
										@"oAithInfo", @"oAithInfo",
										nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:prefsDict];
	
	
	_panel = [NSOpenPanel openPanel];
	_uploadInProgress = FALSE;
	
	

}

-(void)applicationDidFinishLaunching:(NSNotification *)notification {

	// get OS version for notification center use in 10.8+
	GetSystemVersion(&_OSVersionMajor, &_OSVersionMinor, &_OSVersionBugfix);
	if (_OSVersionMinor >= 8) {
		_unc = [NSUserNotificationCenter defaultUserNotificationCenter];
		[_unc setDelegate:self];
	}
	
	// set up global hot keys...
	DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];

	// screen capture: ctrl-shift-4
	if (![c registerHotKeyWithKeyCode:kVK_ANSI_4 modifierFlags:(NSControlKeyMask | NSShiftKeyMask) target:self action:@selector(screenCaptureHotKeyEvent:) object:nil]) {
		NSLog(@"Unable to register hotkey for Screen Capture");
	}

	// upload file: ctrl-shift-G
	if (![c registerHotKeyWithKeyCode:kVK_ANSI_G modifierFlags:(NSControlKeyMask | NSShiftKeyMask) target:self action:@selector(uploadFileHotKeyEvent:) object:nil]) {
		NSLog(@"Unable to register hotkey for File Upload");
	}
	
	// register app delegate as service provider
	[NSApp setServicesProvider:self];
	
	// make sure guppie in background
	[NSApp hide:self];

	
	
}


-(void)screenCaptureAndUpload {
	
	NSTask *theProcess;
	__block BOOL captureSuccess;
	__block NSString *captureFilename;
	BOOL uploadSuccess;
	
	theProcess = [[NSTask alloc] init];
	[theProcess setLaunchPath:@"/usr/sbin/screencapture"];
	// use arguments to set save location
	[theProcess setArguments:[NSArray arrayWithObjects:@"-c", @"-i", @"-t", @"png", nil]];
	
	theProcess.terminationHandler = ^(NSTask *task){
		NSLog(@"termination handler");
		
		NSData *pngImage = [[NSPasteboard generalPasteboard] dataForType:NSPasteboardTypePNG];
		if ([pngImage length] > 0) {
			NSLog(@"Got PNG Image of size: %li", [pngImage length]);
			
			// lets make temporary file for uploading...
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			
			[df setTimeStyle:NSDateFormatterLongStyle];
			[df setDateStyle:NSDateFormatterShortStyle];
			NSMutableString *timestamp = [NSMutableString stringWithString:[df stringFromDate:[NSDate date]]];
			
			[timestamp replaceOccurrencesOfString:@" " withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [timestamp length])];
			[timestamp replaceOccurrencesOfString:@"/" withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [timestamp length])];
			[timestamp replaceOccurrencesOfString:@":" withString:@"_" options:NSLiteralSearch range:NSMakeRange(0, [timestamp length])];
			
			NSString *tmpFilename = [NSTemporaryDirectory() stringByAppendingFormat:@"%@%@%@", @"GuppieScreenShot-", timestamp, @".PNG"];
			captureFilename = [NSString stringWithString:tmpFilename];
			NSLog(@"saving to file: %@", tmpFilename);
			
			[pngImage writeToFile:captureFilename atomically:FALSE];
			
			captureSuccess = TRUE;
		} else {
			NSLog(@"ZERO BYTE PNG IMAGE");
			captureSuccess = FALSE;
		}
	};
	
	[[NSPasteboard generalPasteboard] clearContents];
	[theProcess launch];
	[theProcess waitUntilExit];
	
	if (captureSuccess) {
		NSLog(@"Capture Successful! (%i)", [theProcess terminationStatus]);
		
		// now upload file...
		uploadSuccess = [self uploadFile:captureFilename];
//		NSRunAlertPanel(@"Upload Success", [NSString stringWithFormat:@"Upload Success file stored at %@", captureFilename], @"ok", nil, nil);
		
		
	} else {
		NSRunAlertPanel(@"Capture FAILURE", @"Capture FAILURE", @"bad", nil, nil);
		NSLog(@"Capture termReason! (%li)", [theProcess terminationReason]);
	}
}

- (IBAction)screenCapture:(id)sender {
	
	[self screenCaptureAndUpload];
	
}

-(void)screenCaptureHotKeyEvent:(NSEvent *)ev {
	[self screenCaptureAndUpload];
}

-(BOOL)uploadFile:(NSString *)filename {
	
//	put in background...	
	[NSApp hide:self];

	_curFilename = filename;
	
	NSData *imageData = [NSData dataWithContentsOfFile:_curFilename];

	NSString *boundary = @"------GuppieX";
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.imgur.com/2/upload.json"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 512];
	
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: attachment; form-data; name=\"key\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"ac603c8800b9839ae7fc547df3858ecc\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Disposition: attachment; form-data; name=\"image\"; filename=\"gupfile\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postData appendData:[NSData dataWithData:imageData]];
	[postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSInteger postsize = [postData length] + 512;
	[request setValue:[NSString stringWithFormat:@"%ld", postsize] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:postData];
	
	// create NSURLConnection for asynchronous transfer
	[self setUploadInProgress:TRUE];

	NSURLConnection *uploadURLCon = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:FALSE];
	[uploadURLCon setDelegateQueue:[NSOperationQueue mainQueue]];
	[uploadURLCon start];
	
	
	return TRUE;
}

//
// SERVICE method
- (void)guppieService:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {

	NSArray *foundURLs = [pboard readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]] options:nil];

	NSURL *url = [foundURLs objectAtIndex:0];

	if ([url isFileURL]) {
		NSLog(@"File: %@", [url path]);
		[self uploadFile:[url path]];
	}
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	_responseData = [[NSMutableData alloc] init]; // _data being an ivar
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	[_responseData appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
	// Handle the error properly
	[self setUploadInProgress:FALSE];
	[NSAlert alertWithError:error];
}

-(void)connection:(NSURLConnection*)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
//	NSLog(@"Upload Status: %li of %li", totalBytesWritten, totalBytesExpectedToWrite);
	float pcntUploaded = truncf(100.0f * totalBytesWritten / (float)totalBytesExpectedToWrite);
	_progressMsg = [NSString stringWithFormat:@"%@ %3.0f%@", @"Upload is ", roundf(pcntUploaded), @"% complete..."];
}


-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
	[NSApp hide:self];

	// get resulting JSON
	NSString *JSONString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
	
	NSLog(@"Request Return: %@", JSONString);
	
	// dig down into result and retrieve imgur page URL
	NSDictionary *responseDict = [JSONString JSONValue];
	NSDictionary *uploadDict = [responseDict objectForKey:@"upload"];
	NSDictionary *linksDict = [uploadDict objectForKey:@"links"];
	NSString *imgurPageURL = [linksDict objectForKey:@"imgur_page"];
	[[self URLLabel] setStringValue:[imgurPageURL stringByAppendingString:@" copied"]];
	
	// prep NSPasteboard
	NSPasteboard *pBoard = [NSPasteboard generalPasteboard];
	[pBoard clearContents];
	[pBoard writeObjects:[NSArray arrayWithObject:imgurPageURL]];
	
	if (_OSVersionMinor < 8) {
		// set up popover for showing resulting URL
		[self performSelector:@selector(hidePopover:) withObject:nil afterDelay:7.0];
		[[self URLPopover] showRelativeToRect:[_statusItemView bounds] ofView:_statusItemView preferredEdge:NSMaxYEdge];
	} else {
		
		[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(sendNotification:) userInfo:[NSArray arrayWithObjects:imgurPageURL, _curFilename, nil] repeats:FALSE];
		
	}
	
	[self setUploadInProgress:FALSE];
	
}

-(void)sendNotification:(NSTimer *)timer {

	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = @"File Uploaded to imgur...";
	notification.subtitle = [[timer userInfo] objectAtIndex:0];
	notification.informativeText = [[[[timer userInfo] objectAtIndex:1] pathComponents] lastObject];
	[_unc deliverNotification:notification];
	
}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {

	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[notification subtitle]]];

}

-(void)setUploadInProgress:(BOOL)boolval{

	_uploadInProgress = boolval;
	
	[_statusItemView setUploadInProgress:boolval];
	[[self uploadMenuItem] setEnabled:!_uploadInProgress];
	[[self screenCaptureMenuItem] setEnabled:!_uploadInProgress];
	
	if (!_uploadInProgress) {
		[_uploadMenuItem setTitle:@"Upload to imgur..."];
		[_progressUpdateTimer invalidate];
	} else {
		_progressUpdateTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(updateMenu:) userInfo:[self uploadMenuItem] repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:_progressUpdateTimer forMode:NSDefaultRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:_progressUpdateTimer forMode:NSEventTrackingRunLoopMode];
	}
}

-(void)updateMenu:(NSTimer *)timer {
	NSMenuItem *mi = [timer userInfo];
	if (_progressMsg) [mi setTitle:_progressMsg];
}


-(void)hidePopover:(id)sender {
	[[self URLPopover] performClose:nil];
}

-(void)uploadFileHotKeyEvent:(NSEvent *)ev {
	[self uploadFiles:nil];
}

-(IBAction)uploadFiles:(id)sender {
			
	[_panel setAllowsMultipleSelection:FALSE];
	[_panel setAllowedFileTypes:[NSArray arrayWithObjects:@"JPG", @"JPEG", @"GIF", @"PNG", @"PDF", @"TIF", @"TIFF", @"BMP", @"GIF", nil]];
	
	if ([_panel runModal] == NSFileHandlingPanelOKButton) {
		
		NSURL *url = [[_panel URLs] objectAtIndex:0];
		if ([url isFileURL]) {
			NSLog(@"File: %@", [url path]);
			
			[self uploadFile:[url path]];

		}
	}
}
	
-(IBAction)openPreferences:(id)sender {
	
	[NSApp activateIgnoringOtherApps:TRUE];
	if (!_prefsWindow) {
		_prefsWindow = [[SAGUPPreferencesWC alloc] initWithWindowNibName:@"SAGUPPreferences"];
	}
	
	if (_prefsWindow) [_prefsWindow showWindow:nil];
	
}

-(IBAction)checkForUpdates:(id)sender {
	NSRunAlertPanel(@"Checking for updates...", @"Live Update not currently available", @"Cancel", nil, nil);

}
-(IBAction)quit:(id)sender {
	[[NSApplication sharedApplication] terminate:nil];
	
}


@end

//
//  SAGUPPreferencesWC.m
//  guppie
//
//  Created by Dan Auerbach on 10/10/12.
//  Copyright (c) 2012 SoupyApps. All rights reserved.
//

#import "SAGUPPreferencesWC.h"

@interface SAGUPPreferencesWC ()

@end

@implementation SAGUPPreferencesWC
@synthesize prefsToolBar;
@synthesize prefPaneGeneral;
@synthesize prefPaneImgurPro;
@synthesize prefPaneEvenMore;
@synthesize prefsTabView;
@synthesize prefTabGeneral;
@synthesize prefTabImgurPro;
@synthesize prefTabEvenMore;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
//#TO DO
//	NEED WORK HERE TP
	[[self prefsToolBar] setSelectedItemIdentifier:@"prefGeneralToolbarItem"];
	[[self prefsTabView] selectTabViewItemAtIndex:0];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(BOOL)windowShouldClose:(id)sender {
	return TRUE;
}


-(NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	
	return [NSArray arrayWithObjects:
			  self.prefPaneGeneral,
			  self.prefPaneImgurPro,
			  self.prefPaneEvenMore, nil];
}

- (IBAction)activateGeneralPrefPane:(id)sender {
	[[self prefsTabView] selectTabViewItem:[self prefTabGeneral]];
}

- (IBAction)activateImgurProPrefPane:(id)sender {
	[[self prefsTabView] selectTabViewItem:[self prefTabImgurPro]];
}

- (IBAction)activateEvenMorePrefPane:(id)sender {
	[[self prefsTabView] selectTabViewItem:[self prefTabEvenMore]];
}

-(BOOL)readPrefs {
	
	
	return TRUE;
}
-(BOOL)savePrefs {
	return TRUE;
}
@end

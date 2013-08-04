//
//  SAGUPPreferencesWC.h
//  guppie
//
//  Created by Dan Auerbach on 10/10/12.
//  Copyright (c) 2012 SoupyApps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SAGUPPreferencesWC : NSWindowController <NSWindowDelegate>

- (IBAction)activateGeneralPrefPane:(id)sender;
- (IBAction)activateImgurProPrefPane:(id)sender;
- (IBAction)activateEvenMorePrefPane:(id)sender;
@property (weak) IBOutlet NSToolbar *prefsToolBar;
@property (weak) IBOutlet NSToolbarItem *prefPaneGeneral;
@property (weak) IBOutlet NSToolbarItem *prefPaneImgurPro;
@property (weak) IBOutlet NSToolbarItem *prefPaneEvenMore;

@property (weak) IBOutlet NSTabView *prefsTabView;
@property (weak) IBOutlet NSTabViewItem *prefTabGeneral;
@property (weak) IBOutlet NSTabViewItem *prefTabImgurPro;
@property (weak) IBOutlet NSTabViewItem *prefTabEvenMore;

@end

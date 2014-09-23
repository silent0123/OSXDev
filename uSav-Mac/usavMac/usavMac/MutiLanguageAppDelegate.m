//
//  MutiLanguageAppDelegate.m
//  usavMac
//
//  Created by NWHKOSX49 on 16/7/13.
//  Copyright (c) 2013 nwStor. All rights reserved.
//

#import "MutiLanguageAppDelegate.h"
#import "mainWindowController.h"
#import "USAVLock.h"
#import "workingController.h"
#import "USAVClient.h"

@implementation MutiLanguageAppDelegate
@synthesize statusMenu = _statusMenu;
@synthesize statusBar = _statusBar;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if ([USAVClient current] == nil)
	{
        [[USAVClient alloc] init];
    }
    [self.statusMenu setDelegate:self];
    [self.statusMenu setAutoenablesItems:NO];
 
    // Insert code here to initialize your application
    if ([[USAVLock defaultLock] isLogin]) {
        workingWindowController = [[workingController alloc] initWithWindowNibName:@"workingController"];        
        [workingWindowController  showWindow:self];
        [[USAVLock defaultLock] setMainWindowOpenOn];
    } else {
        windowController = [[mainWindowController alloc] initWithWindowNibName:@"mainWindowController"];
        [windowController showWindow:self];
    }
}

- (IBAction)settingPressed:(id)sender {
    if ([[USAVLock defaultLock] isLogin]) {
    }
}

- (IBAction)logout:(id)sender {
    if ([[USAVLock defaultLock] isLogin]) {
        [USAVClient current].userHasLogin = NO;
        [[USAVLock defaultLock] setUserLoginOff];
    
        [NSApp terminate:nil];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (IBAction)openWorkingWindow:(id)sender {
    if([[USAVLock defaultLock] isLogin] && ![[USAVLock defaultLock] isMainWindowOpen]) {
        [self.window orderOut:self];
        self.wc = [[workingController alloc] initWithWindowNibName:@"workingController"];
        [self.wc showWindow:self];
        [[USAVLock defaultLock] setMainWindowOpenOn];
    }
}

- (void) awakeFromNib {
    [self.menuItemSetting setTitle:NSLocalizedString(@"Setting", @"")];
    [self.menuItemQuit setTitle:NSLocalizedString(@"QuitUsav", @"")];
    [self.menuItemOpenWorkingWindow setTitle:NSLocalizedString(@"OpenWorkingWindow", @"")];
    [self.menuItemLogOut setTitle:NSLocalizedString(@"LogOut", @"")];

    [self.menuItemOpenWorkingWindow setEnabled:YES];
    [self.menuItemLogOut setEnabled:YES];
    [self.menuItemSetting setEnabled:YES];
  

    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.title = @"uSav";
    
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
}

@end

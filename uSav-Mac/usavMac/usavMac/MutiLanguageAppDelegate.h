//
//  MutiLanguageAppDelegate.h
//  usavMac
//
//  Created by NWHKOSX49 on 16/7/13.
//  Copyright (c) 2013 nwStor. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class mainWindowController;
@class workingController;

@interface MutiLanguageAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
{
    mainWindowController* windowController;
    workingController* workingWindowController;
    
}

@property (weak) IBOutlet NSMenuItem *menuItemQuit;
@property (weak) IBOutlet NSMenuItem *menuItemLogOut;
@property (weak) IBOutlet NSMenuItem *menuItemSetting;
@property (weak) IBOutlet NSMenuItem *menuItemOpenWorkingWindow;


@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong) workingController *wc;

@property (strong, nonatomic) NSStatusItem *statusBar;

@end

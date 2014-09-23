//
//  AppDelegate.m
//  uSav-NewMac
//
//  Created by Luca on 23/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet MainViewController *mainViewController;

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    
    //创建一个MainViewController
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    //将它添加到主界面
    [self.window.contentView addSubview:self.mainViewController.view];
    self.mainViewController.view.frame = [self.window.contentView bounds];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

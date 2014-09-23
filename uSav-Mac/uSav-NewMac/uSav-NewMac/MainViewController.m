//
//  MainViewController.m
//  uSav-NewMac
//
//  Created by Luca on 23/9/14.
//  Copyright (c) 2014年 nwstor. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark TableView dataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 5;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"FilenameColumn"]) {
        
        cell.textField.stringValue = @"HELLO FILE";
        
    } else if ([tableColumn.identifier isEqualToString:@"StatusColumn"]) {
        
        cell.textField.stringValue = @"SUCCEED";
        //cell.textField.font = [NSFont systemFontOfSize:14];
        
    }
    
    return cell;
}

@end

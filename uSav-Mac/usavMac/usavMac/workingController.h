//
//  workingController.h
//  usavMac
//
//  Created by NWHKOSX49 on 19/7/13.
//  Copyright (c) 2013 nwStor. All rights reserved.
//
#import <Cocoa/Cocoa.h>

@interface workingController : NSWindowController<NSDraggingDestination, NSPasteboardItemDataProvider, NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate>
@property (weak) IBOutlet NSTableView *tbEditPermission;
@property (weak) IBOutlet NSTableView *tbMembers;
@property (weak) IBOutlet NSTableView *tbEditContact;
@property (weak) IBOutlet NSTextField *txtTileMain;
@property (weak) IBOutlet NSTextField *txtTileSub;
@property (weak) IBOutlet NSTableView *tbHistory;
@property (weak) IBOutlet NSTextField *txtVersionNumber;

@property (weak) IBOutlet NSTableView   *tbFileAndDir;
@property (weak) IBOutlet NSTableColumn *colStatus;
@property (weak) IBOutlet NSTableColumn *colCancel;
@property (weak) IBOutlet NSTableColumn *colFileName;
@property (weak) IBOutlet NSTableColumn *colEditPCheck;
@property (weak) IBOutlet NSTableColumn *colEditPContact;
@property (weak) IBOutlet NSTableColumn *colContact;
@property (weak) IBOutlet NSTableColumn *colMemberName;
@property (weak) IBOutlet NSTableColumn *colMemberDelete;


@property (weak) IBOutlet NSTableColumn *colHistoryOperation;
@property (weak) IBOutlet NSTableColumn *colHistoryOperator;
@property (weak) IBOutlet NSTableColumn *colHistoryStatus;
@property (weak) IBOutlet NSTableColumn *colHistoryTime;


@property (weak) IBOutlet NSScrollView *scrollViewGroupAndContacts;
@property (weak) IBOutlet NSScrollView *scrollViewMembers;
@property (weak) IBOutlet NSScrollView *scrollViewContact;
@property (weak) IBOutlet NSScrollView *scrollViewHistory;

@property (weak) IBOutlet NSScrollView *scrollViewMain;
@property (weak) IBOutlet NSButton *btnContactRename;

@property (weak) IBOutlet NSButton *btnContactDelete;
@property (weak) IBOutlet NSButton *btnAddGroupMember;
@property (weak) IBOutlet NSButton *btnEncrypt;
@property (weak) IBOutlet NSButton *btnEditPermission;
@property (weak) IBOutlet NSButton *btnDecrypt;
@property (weak) IBOutlet NSButton *btnHistory;
@property (weak) IBOutlet NSButton *btnDelete;
@property (weak) IBOutlet NSButton *btnCancel;
@property (weak) IBOutlet NSTextField *txtLastOperation;
@property (weak) IBOutlet NSButton *btnAddGroup;
@property (weak) IBOutlet NSButton *btnAddFriend;
@property (weak) IBOutlet NSButton *btnContactList;
@property (weak) IBOutlet NSProgressIndicator *progressBar;

@property (strong) IBOutlet NSView *viewEditPermission;
@property (weak) IBOutlet NSView *view;
@property (strong, nonatomic) NSProgressIndicator * bar;

@end

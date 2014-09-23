//、、、、、//
//  workingController.m
//  usavMac
//
//  Created by NWHKOSX49 on 19/7/13.
//  Copyright (c) 2013 nwStor. All rights reserved.
///Users/nwStor/Desktop/Screen Shot 2013-07-27 at 10.19.00 AM.png
#define usav 0
#define plain 1
#define conflict 3

#define encrypting 0
#define noOperation 8
#define canceled 2
#define done 3
#define decryption 4
#define failed 5

#define include 1
#define exclude 0
#define deleting 11
#define editPermission 10
#define editPermission2 13
#define editContact 14
#define decryptionDone 15

#define keyNumberAdjusts 0
#define keyBufferSize 2;

#define encrypt 19
#define decrypt 1
#define history 33
#define delete 4
#define initial 20
#define manuallyDelete 9
firstLoad = 1;

#import "workingController.h"
#import "USAVClient.h"
#import "API.h"
#import "GDataXMLNode.h"
#import "UsavCipher.h"
#import "NSData+Base64.h"
#import "UsavStreamCipher.h"
#import "USAVLock.h"
int accumulat;
int tempAcc;
int inLoadingContactList;
int edit_permission_cliced;
int aimedPermissions;
#define MAXRESULT 200;

@interface workingController ()
@property (strong, nonatomic) NSFileManager *fileManager;
@property (nonatomic, strong) NSPopUpButton *pullDownList;
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) NSMutableArray *opStatus;
@property (nonatomic, strong) NSMutableArray *btnStatus;
@property (nonatomic, strong) NSMutableArray *keyPool;
@property (nonatomic, strong) NSMutableArray *keyRemainedPool;
@property (nonatomic, strong) NSMutableArray *arrayOfGroups;
@property (nonatomic, strong) NSMutableArray *arrayOfContacts;
@property (nonatomic, strong) NSMutableArray *usedKeys;
@property (nonatomic, strong) NSString *keyIdString;
@property (nonatomic) int preState;
@property (nonatomic, strong) NSAlert *tmpAlert;
@property (nonatomic, strong) NSString *tmp_filepath;
@property (nonatomic, strong) NSMutableArray *ArrCheckMarks;
@property (nonatomic, strong) NSMutableArray *checkmarkChanges;
@property (nonatomic, strong) NSMutableArray *originCheckmark;

@property (nonatomic, strong) NSTableView *tbContacts;
@property (nonatomic) int poolSize;
@property (nonatomic) int keyIndex;

@property (nonatomic, strong) NSArray *tempPaths;
@property (nonatomic, strong) NSMutableArray *fileNames;
@property (nonatomic) int inputFileType;
@property (nonatomic) int firstFileType;

@property (nonatomic, strong) NSArray *permissions;

@property (nonatomic) int numOfRow;
@property (nonatomic) BOOL basketEmpty;

@property (nonatomic) BOOL useDefaultOutputPath;
@property (nonatomic, strong) NSString *defaultEncryptOutputPath;
@property (nonatomic, strong) NSString *defaultDecryptOutputPath;
@property (nonatomic) BOOL okState;

@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic) int actionState;
@property (nonatomic) int lastActionState;

@property (nonatomic) BOOL actionStart;
@property (nonatomic) int selectedGroup;

@property (nonatomic) int groupIndex;
@property (nonatomic) BOOL contactReady;
@property (nonatomic) BOOL startLoadMember;
@property (nonatomic) BOOL loadNothing;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatterLocal;
@property (nonatomic, strong) NSDateFormatter *dateFormatterRemote;

@property (nonatomic) int successPermissions;
//@property (nonatomic) int aimedPermissions;
@property (nonatomic) int onTheFront;

@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *friendName;
@property (nonatomic) int rowindex;
@property (nonatomic) BOOL clearMember;
@property (nonatomic) int memberDeleteIndex;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic) int maxResult;
@property (nonatomic) NSTimeInterval secondsPerYear;
@property (nonatomic, strong) NSMutableArray *logList;

@property (nonatomic) BOOL groupReady;
@property (nonatomic) int selectedRowi;
@property (nonatomic) BOOL cancelEditpermissonPressed;

@end

@implementation workingController

- (NSTimeInterval)secondsPerYear
{
    if(!_secondsPerYear) {
        _secondsPerYear = 24 * 60 * 60 * 365;
    }
    return _secondsPerYear;
}

- (NSMutableArray*)logList
{
    if(!_logList) {
        _logList = [NSMutableArray arrayWithCapacity:0];
    }
    return _logList;
}



- (NSDate *)startTime
{/*
  if(!_startTime) {
  _startTime = [[NSDate alloc] initWithTimeIntervalSinceNow:-self.secondsPerYear];
  }*/
    //return _startTime;
    return [[NSDate alloc] initWithTimeIntervalSinceNow:-self.secondsPerYear];
}

- (NSDate *)endTime
{/*
  if(!_endTime) {
  _endTime = [NSDate date];
  }
  return _endTime;*/
    return [NSDate date];
}

- (int)maxResult
{
    return MAXRESULT;
}

- (NSDateFormatter*) dateFormatter
{
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        [_dateFormatter setLocale:[NSLocale systemLocale]];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_dateFormatter setDateFormat:@"yyyy-M-d'T'HH:mm:ss'Z'"];
    }
    return _dateFormatter;
}

- (NSDateFormatter*) dateFormatterRemote
{
    if(!_dateFormatterRemote) {
        _dateFormatterRemote = [[NSDateFormatter alloc] init];
        
        [_dateFormatterRemote setLocale:[NSLocale systemLocale]];
        [_dateFormatterRemote setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_dateFormatterRemote setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    return _dateFormatterRemote;
}

- (NSDateFormatter*) dateFormatterLocal
{
    if(!_dateFormatterLocal) {
        _dateFormatterLocal = [[NSDateFormatter alloc] init];
        
        [_dateFormatterLocal setLocale:[NSLocale systemLocale]];
        [_dateFormatterLocal setTimeZone:[NSTimeZone localTimeZone]];
        [_dateFormatterLocal setDateFormat:@"yyyy-M-d HH:mm:ss"];
    }
    return _dateFormatterLocal;
}

- (IBAction)historyPressed:(id)sender {
   /* [self.scrollViewMain setHidden:YES];
    [self.scrollViewHistory setHidden:NO];
    
    [self.btnContactList setEnabled:NO];
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"File History", @"")]];
    [self.txtTileMain setStringValue:NSLocalizedString(@"        File History", @"")];
    [self.txtTileSub setStringValue:[self.fileNames objectAtIndex:0]];*/
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:[self.paths objectAtIndex:0]];
    NSString *keyIdString = [keyId base64EncodedString];
    self.keyIdString = keyIdString;
    /*self.actionState = history;
    [self determineBtnStateBy:self.actionState];
    */
    [self ListKeyLogById: self.keyIdString];
}

- (IBAction)renameGroup:(id)sender {
     [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"Rename Group", @"")]];
    self.groupName = nil;
    self.groupName = [self input:NSLocalizedString(@"Rename group", @"") defaultValue:NSLocalizedString(@"", @"")];
    if( self.groupName) {
        [self editGroupNameFrom:[[self.arrayOfGroups objectAtIndex:self.selectedGroup] objectAtIndex:0] to: self.groupName];
    }
}

- (IBAction)deleteContact:(id)sender {
    if(accumulat > 0) return;
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"Delete Contact", @"")]];
    if(self.selectedGroup != -1) {
        [self deleteGroupBuildRequest:[[self.arrayOfGroups objectAtIndex:self.selectedGroup] objectAtIndex:0]];
    } else {
        [self deleteContactBuildRequest:[[self.arrayOfContacts objectAtIndex:self.rowindex - [self.arrayOfGroups count]] objectForKey:@"friendEmail"]];
    }
}

- (IBAction)addFriend:(id)sender {
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"Add Friend", @"")]];
    self.friendName = nil;
    self.friendName = [self input:NSLocalizedString(@"Add Friend", @"") defaultValue:NSLocalizedString(@"", @"")];
    
    if(accumulat == 1) {
        accumulat = 0;
        return;
    }
    
    if ([self.friendName  length] > 4 && [self.friendName  length] <= 32) {
        if (![self isValidEmail:self.friendName ]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"InvalidEmail", @"")];
            [alert runModal];
        }
        [self addFriendRequest:self.friendName];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"AddFriendFault", @"")];
        [alert runModal];
    }
}

- (BOOL)isValidEmail: (NSString *) email
{
    if ([email length] < 5 || [email length] > 100) {
        return false;
    }
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.+@.+\\..+$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

- (IBAction)AddGroupMember:(id)sender {
     [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"Add Group Member", @"")]];
    self.friendName = nil;
    self.friendName = [self input2:NSLocalizedString(@"Select member from list", @"") defaultValue:NSLocalizedString(@"", @"")];
    NSMutableArray *group = [self.arrayOfGroups objectAtIndex:self.selectedGroup];
    
    if(self.friendName && [self.friendName length] > 3 ) {
        //[self addFriendRequest:self.friendName];
        [self addGroupMember:[group objectAtIndex:0] forContact:self.friendName];
    }
}

- (IBAction)addGroup:(id)sender {
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"Add Group", @"")]];

    self.groupName = nil;
    self.groupName = [self input:NSLocalizedString(@"Add Group", @"") defaultValue:NSLocalizedString(@"", @"")];
    if(accumulat == 1) {
        accumulat = 0;
        return;
    }
    
    if ([self.groupName length] > 0 && [self.groupName length] <= 49) {
        [self addGroupBuildRequest:self.groupName];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"AddGroupFault", @"")];
        [alert runModal];
    }
    /*
    if(self.groupName) {
        [self addGroupBuildRequest:self.groupName];
    }*/
}

- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:NSLocalizedString(@"OK", @"")
                                   alternateButton:NSLocalizedString(@"Cancel", @"")
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    self.tmpAlert = alert;
    
    NSButton *butCan = [[alert buttons] objectAtIndex:1];
    [butCan  setTarget:self];
    [butCan  setAction:@selector(cancelContact)];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
}
- (void)cancelContact {
    accumulat = 1;
    [NSApp endSheet: [self.tmpAlert window]];
    
}

- (NSString *)input2: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:NSLocalizedString(@"OK", @"")
                                   alternateButton:NSLocalizedString(@"Cancel", @"")
                                       otherButton:nil
                         informativeTextWithFormat:@""];
   self.pullDownList = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 250, 30)];
    
    
    [self.pullDownList setPullsDown:YES];
    [self.pullDownList addItemWithTitle:@""];
    NSString *target;
    NSMutableArray *group;
    
    
    BOOL alreadyIn;
    for (id i in self.arrayOfContacts) {
        target = [i objectForKey:@"friendEmail"];
        group = [self.arrayOfGroups objectAtIndex:self.selectedGroup];
        alreadyIn= false;
        
        for (int j = 1; j < [group count]; j++) {
            if ([[[group objectAtIndex:j] objectForKey:@"friendEmail"] isEqualToString:target]) {
                alreadyIn = true;
                break;
            }
        }
        if(!alreadyIn) {
            [self.pullDownList addItemWithTitle:target];
        }
    }
    
    [self.pullDownList setTarget:self];
    [self.pullDownList setAction:@selector(pullDownSelected:)];

    [alert setAccessoryView:self.pullDownList];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        //[input validateEditing];
        return [self.pullDownList titleOfSelectedItem];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
}

- (void)pullDownSelected:(id)sender {
    //[self.pullDownList selectItemAtIndex:[self.pullDownList indexOfSelectedItem]];
    [self.pullDownList setTitle:[self.pullDownList titleOfSelectedItem]];
}

- (IBAction)contactPressed:(id)sender {
    self.loadNothing = false;
    self.startLoadMember = false;
    
    if(self.actionState != editContact) {
        [self.txtTileMain setStringValue:NSLocalizedString(@"      Contact List", @"")];

        [self.txtTileSub setStringValue:@""];
        [self.btnContactList setTitle:NSLocalizedString(@"Back", @"")];
        [self.scrollViewMain setHidden:YES];
        [self.scrollViewMembers setHidden:NO];

        [self.scrollViewContact setHidden:NO];
        self.actionState = editContact;
    
        [self determineBtnStateBy: self.actionState];
        if(!self.contactReady) {
            self.groupReady = NO;
            [self listTrustedContactStatus];
        }else {
            [self.tbEditContact reloadData];
        }
    } else {
        [self.txtTileMain setStringValue:NSLocalizedString(@"Drag and Drop Files", @"")];
        [self.txtTileSub setStringValue:@"to the window below"];
        
        [self.btnContactList setTitle:NSLocalizedString(@"Contact", @"")];
        [self.scrollViewMain setHidden:NO];
        [self.scrollViewMembers setHidden:YES];
        [self.btnContactList setEnabled:NO];
        [self.scrollViewContact setHidden:YES];
        self.actionState = noOperation;
        [self determineBtnStateBy: self.actionState];
        self.loadNothing = YES;
        [self.tbMembers reloadData];
        self.loadNothing = NO;
        if(!self.contactReady) {
            [self performSelector:@selector(enableContact:) withObject:nil afterDelay:5.0];
        } else {
           [self performSelector:@selector(enableContact:) withObject:nil afterDelay:0.5];
        }
    }
}

- (void)determineBtnStateBy:(int)actionState {
    [self.btnCancel setTitle:NSLocalizedString(@"Done", @"")];
    [self.btnCancel setEnabled:YES];
    self.okState = YES;
    
    switch(actionState) {
        case encrypt: {
            [self.btnEncrypt setEnabled:YES];
            [self.btnEditPermission setEnabled:NO];
            [self.btnDecrypt setEnabled:NO];
            [self.btnHistory setEnabled:NO];
            [self.btnDelete setEnabled:NO];
        }
        break;
        case decrypt: {
            [self.btnEncrypt setEnabled:NO];
            [self.btnEditPermission setEnabled:NO];
            [self.btnDecrypt setEnabled:YES];
            [self.btnHistory setEnabled:NO];
            [self.btnDelete setEnabled:NO];
        } break;
        case editPermission: {
            
            [self.btnEncrypt setEnabled:NO];
            [self.btnEditPermission setEnabled:NO];
            [self.btnDecrypt setEnabled:NO];
            [self.btnHistory setEnabled:NO];
            [self.btnDelete setEnabled:NO];
            [self.btnCancel setEnabled:YES];
            [self.btnCancel setStringValue:NSLocalizedString(@"Done", @"")];
            
        } break;
        case history: {
            [self.btnEncrypt setEnabled:NO];
            [self.btnEditPermission setEnabled:NO];
            [self.btnDecrypt setEnabled:NO];
            [self.btnHistory setEnabled:NO];
            [self.btnDelete setEnabled:NO];
            [self.btnContactList setEnabled:NO];
        } break;
        case delete: {
            [self.btnEncrypt setEnabled:NO];
            [self.btnEditPermission setEnabled:NO];
            [self.btnDecrypt setEnabled:NO];
            [self.btnHistory setEnabled:NO];
            [self.btnDelete setEnabled:NO];
        } break;
        case noOperation: {
            [self.btnEncrypt setEnabled:NO];
            [self.btnEditPermission setEnabled:NO];
            [self.btnDecrypt setEnabled:NO];
            [self.btnHistory setEnabled:NO];
            [self.btnDelete setEnabled:NO];
            [self.btnAddGroup setHidden:YES];
            [self.btnAddFriend setHidden:YES];
            [self.btnAddGroupMember setHidden:YES];
            [self.btnContactDelete setHidden:YES];
            
            [self.btnEncrypt setHidden:NO];
            [self.btnEditPermission setHidden:NO];
            [self.btnDecrypt setHidden:NO];
            [self.btnHistory setHidden:NO];
            [self.btnDelete setHidden:NO];
            [self.btnCancel setHidden:NO];
            [self.btnCancel setEnabled:NO];
            [self.btnContactRename setHidden:YES];
            [self.btnContactDelete setHidden:YES];
        } break;
        case editContact: {
            [self.btnEncrypt setHidden:YES];
            [self.btnEditPermission setHidden:YES];
            [self.btnDecrypt setHidden:YES];
            [self.btnHistory setHidden:YES];
            [self.btnDelete setHidden:YES];
            [self.btnAddGroup setHidden:NO];
            [self.btnAddFriend setHidden:NO];
            [self.btnCancel setHidden:YES];
            //[self.btnContactRename setHidden:YES];
            
        } break;
            
        default:break;
    }

}

- (IBAction)editPermissionPressed:(id)sender {
    //self.actionState = editPermission;
    edit_permission_cliced += 1;

    if(!self.contactReady) {
        [self performSelector:@selector(superReload:) withObject:nil afterDelay:6.0];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"Loading contact list...", @"")];
        [alert runModal];
        [self.btnEditPermission setEnabled:YES];
        if(edit_permission_cliced == 4) {
            self.groupReady = NO;
            edit_permission_cliced = 0;
            
            [self.arrayOfContacts removeAllObjects];
            [self.arrayOfGroups removeAllObjects];
            [self.ArrCheckMarks removeAllObjects];
            
            [self listTrustedContactStatus];
            
            [self.btnEditPermission setEnabled:NO];
            [self performSelector:@selector(enableEditpermission:) withObject:nil afterDelay:6.0];
        }else if(!inLoadingContactList) {
            self.groupReady = NO;
            [self.arrayOfContacts removeAllObjects];
            [self.arrayOfGroups removeAllObjects];
            [self.ArrCheckMarks removeAllObjects];
            
            [self listTrustedContactStatus];
            
            [self.btnEditPermission setEnabled:NO];
            [self performSelector:@selector(enableEditpermission:) withObject:nil afterDelay:5.0];
        }
        return;
    }
    self.actionState = editPermission;

    [self.btnEditPermission setEnabled:NO];
    [self performSelector:@selector(enableEditpermission::) withObject:nil afterDelay:3.0];
    
    tempAcc = 0;
    self.onTheFront = NO;
    int nG = [self.arrayOfGroups count];
    int nC = [self.arrayOfContacts count];
    
    if (!self.contactReady && nG + nC == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"No contact or network error", @"")];
        [alert runModal];
        return;
    }
    
    [self.btnContactList setEnabled:NO];
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""),NSLocalizedString(@"Edit Permission", @"")]];
    
    aimedPermissions = 0;
    self.successPermissions = 0;

    if (self.preState == encrypt) {


        
        [self.scrollViewMain setHidden:YES];
        [self.scrollViewMembers setHidden:NO];
        [self.scrollViewGroupAndContacts setHidden:NO];
        //self.actionState = editPermission;
        
        [self determineBtnStateBy: self.actionState];
        [self.txtTileMain setStringValue:NSLocalizedString(@"     Edit Permission", @"")];
        [self.txtTileSub setStringValue:NSLocalizedString(@"", @"")];
        [self.tbEditPermission reloadData];
    } else {


        
        [self.tbEditPermission reloadData];
        if (self.firstFileType == usav) {
            [self getPermissionForFile:[self.paths objectAtIndex:0]];
        }
    }
    
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        if (sourceDragMask & NSDragOperationGeneric) {
            return NSDragOperationGeneric;
        }
    }
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        //[self.paths addObjectsFromArray:[pboard propertyListForType:NSFilenamesPboardType]];
        if(self.actionState == editContact) {
            return YES;
        }
        if(self.actionState == editPermission && ![self.scrollViewGroupAndContacts isHidden]) return YES;
      
        
        self.tempPaths = [pboard propertyListForType:NSFilenamesPboardType];
        [self rmDupArray:self.tempPaths CorrespondBy:self.paths];
        [self.btnContactList setEnabled:NO];
        if(self.actionStart) {
            return YES;
        }
        //self.numOfRow = [self.files count];
        //[self.tbFileAndDir reloadData];
        [self provideFeatureByFileType];
    }
    return YES;
}

- (void)rmDupArray:(NSMutableArray *)temp CorrespondBy:(NSArray *)base
{
    
    for (id path in base) {
        for (int i = 0; i < [temp count]; i++) {
            NSString *tempPath = [temp objectAtIndex:i];
            if ([path isEqualToString:tempPath]) {
                [temp removeObjectAtIndex:i]; i -= 1;
            }
        }
    }
}

- (void)disableAllButton {
    [self.btnEncrypt setEnabled:NO];
    [self.btnEditPermission setEnabled:NO];
    [self.btnDecrypt setEnabled:NO];
    [self.btnHistory setEnabled:NO];
    [self.btnDelete setEnabled:NO];
}

- (void)pathsByRemovingFolders:(NSArray*) paths {
    //remove folder path for input paths
    NSUInteger n = [paths count];
    NSMutableArray *pathForFiles = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < n; i++)
    {
        NSString *path = [paths objectAtIndex:i];
        BOOL isDir;
        if([[NSFileManager defaultManager]
            fileExistsAtPath:path isDirectory:&isDir] && isDir){
            continue;
        } else{
            //if path is for a file, then added to array
            [pathForFiles addObject:path];
        }
    }
    pathForFiles = [self removeDuplicatePaths: pathForFiles];
    self.tempPaths = pathForFiles;
}

- (void)provideFeatureByFileType
{
    [self pathsByRemovingFolders: self.tempPaths];
    int inputType = [self filetype];
    if (inputType == conflict) {
        //print 'You cannot drag .usav with another t/Users/nwStor/Desktop/josype of files';
        //[self.CancelButton setHidden:NO];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"DiffFileType", @"")];
        [alert runModal];
        return;
    }
    
    if(self.basketEmpty) {
        self.firstFileType = inputType;
        //[self.CancelButton setHidden:NO];
        
        self.basketEmpty = NO;
    } else {
        if(self.firstFileType != inputType) {
            //print 'draged file type don't match previous data';
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"UnmatchFileType", @"")];
            [alert runModal];
            return;
        }
    }
    
    [self.paths addObjectsFromArray:self.tempPaths];
    for (int i = 0; i < [self.tempPaths count]; i++) {
        [self.opStatus addObject: [[NSNumber alloc] initWithInt:noOperation]];
        [self.btnStatus addObject: [[NSNumber alloc] initWithInt:exclude]];
    }
    
    if(self.firstFileType == plain) {
        [self getKeysForPool: [self.tempPaths count]];
    } else if (self.firstFileType == usav) {
        //[self getKeysForUsavFile: self.paths, self.keyIndex];
    }
    
    //self.paths = [self removeDuplicatePaths:self.paths];
    [self getFileNamesFromPaths: self.paths];
    
    self.numOfRow = [self.paths count];
    
    [self.tbFileAndDir reloadData];
    if(self.firstFileType == plain) {
        [self enalbeButtonForPlainFiles];
    } else if (self.firstFileType == usav) {
        if ([self.paths count] > 1) {
        [self enalbeButtonForUsavFiles];
        } else {
            [self enalbeButtonForUsavFile];
        }
    }
}

- (void)getKeysForUsavFile:(NSMutableArray *)paths FromIndex:(int)index {
    int i;
    for (i = index; i < [self.paths count]; i++) {
        [self getKeyBuildRequestForFile:[self.paths objectAtIndex:i]];
    }
}

- (int)chooseAvailableItemStartFrom:(int)index {
    
    for(int i = index; i < [self.opStatus count]; i++) {
        if ([[self.opStatus objectAtIndex:i] integerValue] != canceled && [[self.btnStatus objectAtIndex:i] integerValue] != include && [[self.opStatus  objectAtIndex:i] integerValue] != done) {
            return i;
        }
    }
    return -1;
}

-(void)getKeyBuildRequestForFile:(NSString *)filepath
{
    [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:decryption]];
    [self.tbFileAndDir reloadData];
    
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:filepath];
    
    NSString *keyIdString = [keyId base64EncodedString];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", keyIdString, @"\n"];
    
    ////nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    ////nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyIdString];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    [client.api getKey:encodedGetParam target:(id)self selector:@selector(getKeyResult:)];
}

-(void) getKeyResult:(NSDictionary*)obj {
    self.actionState == noOperation;
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:failed]];
        [self.btnDecrypt setEnabled:YES];
        [self.tbFileAndDir reloadData];
        [self.bar setHidden:YES];
        [self.bar startAnimation:nil];
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:failed]];
        [self.btnDecrypt setEnabled:YES];
        [self.tbFileAndDir reloadData];
        [self.bar setHidden:YES];
        [self.bar startAnimation:nil];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {

        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                int keySize = [[obj objectForKey:@"Size"] integerValue];
                //self.actionState = decryptionDone;
                
                NSString *filePath = [self.paths objectAtIndex:self.keyIndex];
                NSString *path = [filePath stringByDeletingLastPathComponent];
                NSString *filename = [[filePath lastPathComponent] stringByDeletingPathExtension];
                NSString *extension = [[UsavFileHeader defaultHeader] getExtension:filePath];

                filename = [self filenameConflictSovlerForDecrypt:filename forPath:path];
                if (extension) {
                     filename = [NSString stringWithFormat:@"%@%@%@", [filename stringByDeletingPathExtension],@".", extension];
                }
                
                NSMutableString *tempFullPath  = [NSString stringWithFormat:@"%@/%@%@", path,filename,@"-temp"];
                NSMutableString *targetFullPath = [NSString stringWithFormat:@"%@/%@", path,filename];
                self.tmp_filepath = tempFullPath;
                
                BOOL rc = [[UsavStreamCipher defualtCipher] decryptFile:filePath targetFile: tempFullPath keyContent:keyContent];
                
                if (rc == 0 || rc == true) {
                    self.tmp_filepath = targetFullPath;
                    
                    [self.paths replaceObjectAtIndex:self.keyIndex withObject:targetFullPath];
                    [self.fileNames replaceObjectAtIndex:self.keyIndex withObject:[targetFullPath lastPathComponent]];
                    
                    [self.btnCancel setEnabled:YES];
                    [self.btnCancel setTitle:NSLocalizedString(@"Done", @"")];
                    [[NSFileManager defaultManager] moveItemAtPath:tempFullPath toPath:targetFullPath error:nil];

                    [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:done]];
                    [self.tbFileAndDir reloadData];
            
                    self.keyIndex += 1;
                    
                    self.keyIndex = [self chooseAvailableItemStartFrom:self.keyIndex];
                    if (self.keyIndex == -1) {
                        //[self determineBtnStateBy:decrypt];
                        [self.bar setHidden:YES];
                        [self.bar startAnimation:nil];
                        return;
                    }
                    [self getKeyBuildRequestForFile:[self.paths objectAtIndex:self.keyIndex]];
                }
                else {
                    [self.bar setHidden:YES];
                    [self.bar startAnimation:nil];
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
                    [alert runModal];
                }
                return;
            }
            default: {
                [self.bar setHidden:YES];
                [self.bar startAnimation:nil];
                [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:failed]];
                [self.btnDecrypt setEnabled:YES];
                [self.tbFileAndDir reloadData];
            }
                break;
        }
    }
    
   // if ([obj objectForKey:@"httpErrorCode"] != nil)
        //nslog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
}


- (void)getKeysForPool:(int)knum
{
    //get more keys than need
    tempAcc = 0;
    knum += keyBufferSize;
    while(knum--) {
        [self createKeyBuildRequest];
    }
}

- (void)getFileNamesFromPaths:(NSArray *) paths
{
    NSMutableArray * fileNames  = [NSMutableArray arrayWithCapacity:0];
    
    for (id path in paths) {
        [fileNames addObject:[path lastPathComponent]];
    }
    
    self.fileNames = fileNames;
}

- (IBAction)cancelPressed:(id)sender {
    /*if(self.okState) {
        int numFile = [self.opStatus count];
        for (int i = 0; i < numFile; i++) {
            if ([[self.opStatus objectAtIndex:i] integerValue]  != canceled)
                [self.opStatus replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:noOperation]];
        }
        
        if(self.actionState == decrypt) {
            if (numFile > 1) 
                [self enalbeButtonForUsavFiles];
            else
                [self enalbeButtonForUsavFile];
            
        } else if (self.actionState == encrypt) {
            [self enalbeButtonForPlainFiles];
        }
        
        self.okState = NO;
    } else {*/
    [self.bar setHidden:YES];
    if(self.actionState == editPermission) {
        //[self.ArrCheckMarks removeAllObjects];
        [self setPermission];
    }else {
        self.tempPaths = nil;
        [self.txtTileMain setStringValue:NSLocalizedString(@"Drag and Drop Files", @"")];
        
        [self.txtTileSub setStringValue:@"to the window below"];
        [self.btnCancel setTitle:NSLocalizedString(@"btnCancel", @"")];
        //&& self.lastActionState != encrypt
        if(self.actionState == editPermission2 && self.lastActionState != encrypt && !self.onTheFront) {
            [self.btnDecrypt setEnabled:YES];
            [self.btnDelete setEnabled:YES];
            [self.btnEditPermission setEnabled:YES];
            [self.btnHistory setEnabled:YES];
            [self.btnCancel setEnabled:YES];
            self.actionState = noOperation;
            self.onTheFront = YES;
        } else if (self.actionState == history) {
            [self.btnDecrypt setEnabled:YES];
            [self.btnDelete setEnabled:YES];
            [self.btnEditPermission setEnabled:YES];
            [self.btnHistory setEnabled:YES];
        } else {
            self.paths = nil;
            [self.btnDecrypt setEnabled:NO];
            [self.btnDelete setEnabled:NO];
            [self.btnEditPermission setEnabled:NO];
            [self.btnHistory setEnabled:NO];
            [self.opStatus removeAllObjects];
            [self.btnStatus removeAllObjects];
            [self.btnContactList setEnabled:YES];
            self.numOfRow = 0;
            [self.tbFileAndDir reloadData];
            [self.btnCancel setEnabled:NO];
            self.basketEmpty = YES;
            self.preState = noOperation;
        }
        
        self.lastActionState = noOperation;
        [self.logList removeAllObjects];
        self.actionState = noOperation;
        
        [self.btnEncrypt setEnabled:NO];
       

        //}
        [self.keyPool removeAllObjects];
        [self.keyRemainedPool removeAllObjects];
        
        self.keyIndex = 0;
        self.actionStart = false;
      
        //[self.scrollViewMain setHidden:NO];
        [self.scrollViewGroupAndContacts setHidden:YES];
        [self.scrollViewMembers setHidden:YES];
        [self.scrollViewHistory setHidden:YES];
        
        [self.scrollViewMain setHidden:NO];
        [self.usedKeys removeAllObjects];
        //[self.ArrCheckMarks removeAllObjects];
        
        int ngroup = [self.arrayOfGroups count];
        for (int i = 0; i < ngroup; i++) {
            [self.ArrCheckMarks replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:0]];
        }
        
        int nfriend = [self.arrayOfContacts count];
        for (int i = ngroup - 1 > 0 ? ngroup - 1 : 0; i < nfriend + ngroup; i++) {
            [self.ArrCheckMarks replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:0]];
        }
        
        [self.btnEncrypt setHidden:NO];
        [self.btnEditPermission setHidden:NO];
        [self.btnDecrypt setHidden:NO];
        [self.btnHistory setHidden:NO];
        [self.btnDelete setHidden:NO];
        [self.btnAddGroup setHidden:YES];
        [self.btnAddFriend setHidden:YES];
    }
}

-(void)givePermission:(int)p To:(NSString *)name isUser:(int)isUser {
   
    if(self.firstFileType == usav) {
        [self setPermissionMono:self.keyIdString for:name isUser:isUser withPermission:p];
    } else {
        int nKey = [self.usedKeys count];
        for (int i = 0; i < nKey; i++) {
            [self setPermissionMono:[[self.usedKeys objectAtIndex:i] base64EncodedString] for:name isUser:isUser withPermission:p];
        }
    }
}

- (void)setPermission {
    //for group
    [self.btnCancel setEnabled:NO];
    tempAcc = 0;
    int nG = [self.arrayOfGroups count];
    int nC = [self.arrayOfContacts count];
    
    aimedPermissions = 0;
    if (self.preState == encrypt) {
        for (int i = 0; i < nG; i++) {
            if([[self.ArrCheckMarks objectAtIndex:i] integerValue]) {
                [self givePermission:1 To:[[self.arrayOfGroups objectAtIndex:i] objectAtIndex:0] isUser:0];
                aimedPermissions += 1;
            } 
        }
        //for
      
        for (int i = 0; i < nC; i++) {
            if([[self.ArrCheckMarks objectAtIndex:nG + i] integerValue]) {
                [self givePermission:1 To:[[self.arrayOfContacts objectAtIndex: i] objectForKey:@"friendEmail"] isUser:1];
                aimedPermissions += 1;
            }
        } 
    }
    else {
        for (int i = 0; i < nG; i++) {
            if ([[self.checkmarkChanges objectAtIndex:i] integerValue]) {
                
                if([[self.ArrCheckMarks objectAtIndex:i] integerValue]) {
                    [self givePermission:1 To:[[self.arrayOfGroups objectAtIndex:i] objectAtIndex:0] isUser:0];
                    aimedPermissions += 1;
                } else {
                    [self givePermission:0 To:[[self.arrayOfGroups objectAtIndex:i] objectAtIndex:0] isUser:0];
                    aimedPermissions += 1;
                }
            }
        }
        //for 
        int nC = [self.arrayOfContacts count];
        for (int i = 0; i < nC; i++) {
            if ([[self.checkmarkChanges objectAtIndex:nG + i] integerValue]) {

                if([[self.ArrCheckMarks objectAtIndex:nG + i] integerValue]) {
                    [self givePermission:1 To:[[self.arrayOfContacts objectAtIndex: i] objectForKey:@"friendEmail"] isUser:1];
                    aimedPermissions += 1;
                } else {
                    [self givePermission:0 To:[[self.arrayOfContacts objectAtIndex: i] objectForKey:@"friendEmail"] isUser:1];
                    aimedPermissions += 1;
                }
            }
        }
    }
    
    if (!aimedPermissions) {
        self.onTheFront = YES;
        self.actionState = editPermission2;
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"SetPermissionSuccess", @"")];
        [self cancelPressed:nil];
        [alert runModal];
        //[self cancelPressed:nil];
    }
    
    self.preState = noOperation;
}

- (NSString *)getFileName:(NSString *)path
{
    
}

- (void)enalbeButtonForPlainFiles
{
    [self.btnEncrypt setEnabled:YES];
   
    [self.btnCancel setEnabled:YES];
    
    /*
    [self.FileTypeLabel setStringValue:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"FileTypeLabel", @""),NSLocalizedString(@"RawData", @"")]];
    [self.FileNumberLabel setStringValue:[NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"FileNumberLabel", @""), [self.files count]]];
    [self.FileTypeLabel setHidden:NO];
    [self.FileNumberLabel setHidden:NO];
     */
    
}

- (void)enalbeButtonForUsavFile
{
    [self.btnEditPermission setEnabled:YES];
    [self.btnDecrypt setEnabled:YES];
    [self.btnHistory setEnabled:YES];
    [self.btnDelete setEnabled:YES];
    [self.btnCancel setEnabled:YES];
    
}

- (void)enalbeButtonForUsavFiles
{
    [self.btnEditPermission setEnabled:NO];
    [self.btnDecrypt setEnabled:YES];
    [self.btnDelete setEnabled:YES];
    [self.btnCancel setEnabled:YES];
    [self.btnHistory setEnabled:NO];
    /*
    [self removeDuplicateFile];
    [self.FileTypeLabel setStringValue:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"FileTypeLabel", @""),NSLocalizedString(@"ProtectedData", @"")]];
    [self.FileNumberLabel setStringValue:[NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"FileNumberLabel", @""), [self.files count]]];
    [self.FileTypeLabel setHidden:NO];
    [self.FileNumberLabel setHidden:NO];*/
}


- (NSArray *)removeDuplicatePaths:(NSArray *) paths
{
    NSMutableArray *temp = [paths copy];
    NSInteger index = [temp  count] - 1;
    for (id object in [paths reverseObjectEnumerator]) {
        if ([temp  indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
            [temp removeObjectAtIndex:index];
        }
        index--;
    }
    
    return temp;
}


- (void)lightForPlainFiles
{/*
    [self.EncryptionButton setEnabled:YES];
    [self.DecryptionButton setEnabled:NO];
    [self.EditPermissionButton setEnabled:NO];
    [self.HistoryButton setEnabled:NO];
    [self.DeleteButton setEnabled:NO];
    */
    //[self removeDuplicatePaths:self.paths];
    /*
    [self.FileTypeLabel setStringValue:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"FileTypeLabel", @""),NSLocalizedString(@"RawData", @"")]];
    [self.FileNumberLabel setStringValue:[NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"FileNumberLabel", @""), [self.files count]]];
    [self.FileTypeLabel setHidden:NO];
    [self.FileNumberLabel setHidden:NO];*/
}


- (int)filetype {
    //check input file types, if it contains both .usav and plain data, return conflict.
    NSArray* paths = self.tempPaths;
    
    NSUInteger n = [paths count];
    NSString *firstFile = [paths objectAtIndex: 0];
    int typeOfFirstFile;
    //nslog(@"%@", [firstFile pathExtension]);

    if  ([[firstFile pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
        typeOfFirstFile = usav;
    } else {
        typeOfFirstFile = plain;
    }
    
    for (int i = 1; i < n; i++)
    {
        int fileType;
        NSString *extension = [[paths objectAtIndex: i] pathExtension];
        
        if  ([extension caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
            fileType = usav;
        } else {
            fileType = plain;
        }
        
        if (fileType != typeOfFirstFile) {
            return conflict;
        }
    }
    
    return typeOfFirstFile;
}

- (IBAction)decryptPressed:(id)sender {
    [self.bar setHidden:NO];
    [self.bar startAnimation:nil];

    [self.btnContactList setEnabled:NO];
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"Decrypt", @"")]];
    /*[self.txtTileMain setStringValue:NSLocalizedString(@"Decrypt", @"")];
    [self.txtTileSub setStringValue:NSLocalizedString(@"", @"")];*/
    self.actionState = decrypt;
    self.actionStart = YES;
    
    [self disableAllButton];
    
    self.keyIndex = 0;
    self.keyIndex = [self chooseAvailableItemStartFrom:self.keyIndex];
    if (self.keyIndex == -1) {
        [self.bar setHidden:YES];
        [self.bar startAnimation:nil];
        return;
    }
    
    [self getKeyBuildRequestForFile:[self.paths objectAtIndex:self.keyIndex]];
    

}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSMutableArray*)usedKeys
{
    if(!_usedKeys) {
        _usedKeys = [NSMutableArray arrayWithCapacity:0];
        
    }
    return _usedKeys;
}

- (NSMutableArray*)paths
{
    if(!_paths) {
        _paths = [NSMutableArray arrayWithCapacity:0];
        
    }
    return _paths;
}

- (NSMutableArray*)ArrCheckMarks
{
    
    if(!_ArrCheckMarks) {
        _ArrCheckMarks = [NSMutableArray arrayWithCapacity:0];
        
    }
    return _ArrCheckMarks;
}


- (NSMutableArray*)opStatus
{
    if(!_opStatus) {
        _opStatus = [NSMutableArray arrayWithCapacity:0];
        
    }
    return _opStatus;
}

- (NSMutableArray*)keyPool
{
    if(!_keyPool) {
        _keyPool = [NSMutableArray arrayWithCapacity:0];
        
    }
    return _keyPool;
}

- (NSMutableArray*)keyRemainedPool 
{
    if(!_keyRemainedPool ) {
        _keyRemainedPool  = [NSMutableArray arrayWithCapacity:0];
        
    }
    return _keyRemainedPool;
}

- (NSMutableArray*)btnStatus
{
    if(!_btnStatus) {
        _btnStatus = [NSMutableArray arrayWithCapacity:0];
        
    }
    return _btnStatus;
}
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView {
    if (tableView == self.tbEditContact) {
        return YES;
    } else if (tableView == self.tbEditPermission) {
        return YES;
    } else if (tableView == self.tbFileAndDir) {
        return YES;
    }
 
    return NO;
    
}




- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    self.selectedGroup = -1;

    self.loadNothing = NO;
    self.startLoadMember = NO;
    if(![self.scrollViewMain isHidden]) {
        return;
    }
    accumulat = 0;
    //NSLog(@"\n");
    int row = [[notification object] selectedRow];
    //self.selectedGroup = row;
   // NSLog(@"%d", row);
    
    //self.selectedRowi = row;
    /*
    if(![self.scrollViewGroupAndContacts isHidden]) {
        int v = [[self.ArrCheckMarks objectAtIndex:row] integerValue];
        if(v) {
            [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:0]];
        } else {
            [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:1]];
        }
        [self.tbEditPermission reloadData];
    }
   */
    
    int tag = [[notification object] tag];
    
    if (row == -1) {
        [self.btnAddGroupMember setHidden:YES];
        [self.btnContactRename setHidden:YES];
        [self.btnContactDelete setHidden:YES];
        return;
    }
    
    if(tag == 5) {
        self.rowindex = row;
        [self.btnAddGroupMember setHidden:YES];
        [self.btnContactDelete setHidden:NO];
        [self.btnContactRename setHidden:YES];
        
        /*if(self.actionState == editContact) {
            [self.btnContactDelete setHidden:NO];
        }*/
    }
    if (tag == 12) {
        self.rowindex = row;

        self.startLoadMember = YES;
        self.selectedGroup = row;
        if (self.selectedGroup < [self.arrayOfGroups count]) {
                [self.tbMembers reloadData];
        } else {
                self.selectedGroup = -1;
                self.loadNothing = YES;
                [self.tbMembers reloadData];
            }
    }
    if(tag == 0) {
        self.rowindex = row;
        if(self.actionState == editContact) {
            //[self.btnContactDelete setHidden:NO];
            [self.btnContactDelete setHidden:NO];
            
            if(row < [self.arrayOfGroups count]) {
                [self.btnAddGroupMember setEnabled:YES];
                [self.btnAddGroupMember setHidden:NO];
                [self.btnContactRename setHidden:NO];
                [self.btnContactRename setEnabled:YES];
            } else {
                [self.btnContactRename setHidden:YES];
                [self.btnAddGroupMember setHidden:YES];
                return;
            }
            
            //[self.tbEditPermission reloadData];
            /*NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
            [self.tbEditPermission selectRowIndexes:indexSet byExtendingSelection:NO];*/
            self.startLoadMember = YES;
            self.selectedGroup = row;
            if (self.selectedGroup < [self.arrayOfGroups count]) {
                [self.tbMembers reloadData];
            } else {
                self.selectedGroup = -1;
                self.loadNothing = YES;
                [self.tbMembers reloadData];
            }
        }
    }
    
}

- (NSView *)
tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    //NSLog(@"%d     %ld  %d  %d \n",accumulat++, (long)row, self.loadNothing, self.startLoadMember);
    
    //tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    if(self.actionState == history) {
        NSDictionary *log = [self.logList objectAtIndex:row];
        if(tableColumn == self.colHistoryOperation) {
            NSTextField *result =[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
            result.stringValue = [log objectForKey:@"Operation"];
            [result setSelectable:NO];
            [result setBordered:NO];
            [result setEditable:NO];
            [result setBackgroundColor:[NSColor clearColor]];
            return result;
        }
        if(tableColumn == self.colHistoryOperator) {
            NSTextField *result =[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
            result.stringValue = [log objectForKey:@"Doer"];
            [result setSelectable:NO];
            [result setBordered:NO];
            [result setEditable:NO];
            [result setBackgroundColor:[NSColor clearColor]];
            return result;
        }
        if(tableColumn == self.colHistoryStatus) {
            NSTextField *result =[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
            if ([[log objectForKey:@"Result"] integerValue] == 0) {
                result.stringValue= @"Success";
            } else {
                result.stringValue = @"Failed";
            }
            
            [result setSelectable:NO];
            [result setBordered:NO];
            [result setEditable:NO];
            [result setBackgroundColor:[NSColor clearColor]];
            return result;
        }
        if(tableColumn == self.colHistoryTime) {
            NSDate *remoteDate = nil;
            NSError *error = nil;
            [self.dateFormatterRemote getObjectValue:&remoteDate forString:[log objectForKey:@"Date"] range:nil error:&error];
            
            NSTextField *result =[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
            result.stringValue = [self.dateFormatterLocal stringFromDate: remoteDate];

            [result setSelectable:NO];
            [result setBordered:NO];
            [result setEditable:NO];
            [result setBackgroundColor:[NSColor clearColor]];
            return result;
        }
    }
    if(self.loadNothing && (tableColumn == self.colMemberName || tableColumn == self.colMemberDelete)) {
        NSTextField *result =[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
        result.stringValue = @"";
        [result setSelectable:NO];
        [result setBordered:NO];
        [result setEditable:NO];
        [result setBackgroundColor:[NSColor clearColor]];
        return result;
    }
    if (self.startLoadMember) {
        if(tableColumn == self.colMemberName) {
            NSTextField *result = [tableView makeViewWithIdentifier:@"CThree" owner:self];
            if (result == nil) {
                result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
                result.identifier = @"CThree";
            }
            
            if (self.selectedGroup >= 0) {
                int numOfGroup = [self.arrayOfGroups count];
            
                NSArray *group = [self.arrayOfGroups objectAtIndex:self.selectedGroup];
                int numOfMember = [group count];
                int index = row % numOfMember + 1;
                if (index < numOfMember) {
                    result.stringValue = [[group objectAtIndex:index ]  objectForKey:@"friendEmail"];
                } else if (index >= numOfMember) {
                self.startLoadMember = false;
                result.stringValue = @"";
            }
            
            } else 
                result.stringValue = @"";
                [result setBackgroundColor:[NSColor clearColor]];
                [result setSelectable:NO];
                [result setBordered:NO];
                [result setEditable:NO];
            return result;
            } else if(tableColumn == self.colMemberDelete){
                if (self.actionState == editPermission) {
                    NSTextField *result =[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
                    result.stringValue = @"";
                    [result setSelectable:NO];
                    [result setBordered:NO];
                    [result setEditable:NO];
                    [result setBackgroundColor:[NSColor clearColor]];
                    return result;
                } else {
                NSButton *but = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 5, 5)];
                but.identifier = @"memberColumnTwo";
            
                [but setTarget:self];
                [but setAction:@selector(memberDelete:)];
                [but setTag:row];
            
                [but setTitle:NSLocalizedString(@"delete", @"")];
                NSArray *group = [self.arrayOfGroups objectAtIndex:self.selectedGroup];
                int numOfMember = [group count];
                int index = row % numOfMember + 1;
                if (index >= numOfMember) {
                    self.startLoadMember = false;
                }
                return but;
                }
            }
    }
    else if (self.actionState == editPermission) {
               
        if (tableColumn == self.colEditPCheck) {
            NSButton *but = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 5, 5)];
            but.identifier = @"COne";
            [but setButtonType:NSSwitchButton];
            [but setTitle:@""];
            [but setTarget:self];
            [but setAction:@selector(checkSwitch:)];
            [but setTag:row];
            if ([[self.ArrCheckMarks objectAtIndex:row] integerValue])
            {
                [but setState:YES];
            }
             return but;
            
         } else if (tableColumn == self.colEditPContact) {
             //NSTextField *result = [tableView makeViewWithIdentifier:@"CTwo" owner:self];
             //if (result == nil) {
             NSTextField *result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
                //result.identifier = @"CTwo";
             //}
             if (row < [self.arrayOfGroups count]) {
                 result.stringValue = [[self.arrayOfGroups objectAtIndex:row] objectAtIndex:0];
             } else {
                 //NSLog(@"%ld %ld\n",[self.arrayOfContacts count], row - [self.arrayOfGroups count]);

                 result.stringValue = [[self.arrayOfContacts objectAtIndex:row - [self.arrayOfGroups count]] objectForKey:@"friendEmail"];
             }
             
             [result setBackgroundColor:[NSColor clearColor]];
             [result setBordered:NO];
             [result setEditable:NO];
             return result;
             
         } else {
             NSTextField *result =[[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
             result.stringValue = @"";
             [result setSelectable:NO];
             [result setBordered:NO];
             [result setEditable:NO];
             [result setBackgroundColor:[NSColor clearColor]];
             return result;
         }
    }
    else if (self.actionState == editContact) {
       /* NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
        [tableView selectRowIndexes:indexSet byExtendingSelection:NO];
       *//*
        if (tableColumn == self.colEditPCheck) {
            NSButton *but = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 5, 5)];
             but.identifier = @"COne";
             [but setButtonType:NSSwitchButton];
             [but setTitle:@""];
             [but setTarget:self];
             [but setAction:@selector(checkSwitchContact:)];
             [but setTag:row];
            if (self.rowindex == row) {
                [but setEnabled:YES];
            } else {
                [but setEnabled:NO];
            }
             if ([[self.ArrCheckMarks objectAtIndex:row] integerValue])
             {
             [but setState:YES];
             }
             return but;
            return nil;
            
        } *///else if (tableColumn == self.colEditPContact) {
        if (tableColumn == self.colContact) {
            NSTextField *result = [tableView makeViewWithIdentifier:@"CTwo" owner:self];
            if (result == nil) {
                result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
                result.identifier = @"CTwo";
            }
            if (row < [self.arrayOfGroups count]) {
                result.stringValue = [[self.arrayOfGroups objectAtIndex:row] objectAtIndex:0];
            } else {
                result.stringValue = [[self.arrayOfContacts objectAtIndex:row - [self.arrayOfGroups count]] objectForKey:@"friendEmail"];
            }
            [result setBackgroundColor:[NSColor clearColor]];
            [result setSelectable:YES];
            [result setBordered:NO];
            [result setEditable:NO];
            return result;
        }  else {
            NSTextField *result = [tableView makeViewWithIdentifier:@"ColumnTwo" owner:self];
            if (result == nil) {
                result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
                result.identifier = @"ColumnTwo";
            }
            
            [result setBackgroundColor:[NSColor clearColor]];
            [result setEditable:NO];
            [result setBordered:NO];
            return result;
        }
    }
    
else {
    int op = [[self.btnStatus objectAtIndex:row] integerValue];
    int status = [[self.opStatus objectAtIndex:row] integerValue];

    if (tableColumn == self.colFileName) {
        NSTextField *result = [tableView makeViewWithIdentifier:@"ColumnOne" owner:self];
        if (result == nil) {
            result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
            result.identifier = @"ColumnOne";
        }
        result.stringValue = [self.fileNames objectAtIndex:row];
        [result setBordered:NO];
        [result setEditable:NO];
        [result setSelectable:NO];
         [result setBackgroundColor:[NSColor clearColor]];
        if (op == exclude) {
            [result setEnabled:YES];
            
        } else if (op == include) {
            [result setEnabled:NO];
        }
        [result setBackgroundColor:[NSColor clearColor]];
        return result;
    } else if (tableColumn == self.colCancel) {
        NSButton *but = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 5, 5)];
        but.identifier = @"ColumnThree";
 
        [but setTarget:self];
        [but setAction:@selector(includeSwitch:)];
        [but setTag:row];
        
        if (op == exclude) {
            [but setTitle:NSLocalizedString(@"exclude", @"")];
        } else if (op == include) {
            [but setTitle:NSLocalizedString(@"include", @"")];
        }
        if ([[self.opStatus  objectAtIndex:row] integerValue] == done) {
            [but setEnabled:NO];
        }
        return but;
    } else if (tableColumn == self.colStatus){
        NSTextField *result = [tableView makeViewWithIdentifier:@"ColumnTwo" owner:self];
        if (result == nil) {
            result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
            result.identifier = @"ColumnTwo";
        }
        [result setEditable:NO];
        [result setBordered:NO];
        [result setBackgroundColor:[NSColor clearColor]];
        if (status == encrypting) {
            result.stringValue = NSLocalizedString(@"Encrypting...", @"");
            [result setTextColor:[NSColor greenColor]];
        } else if (status == noOperation) {
            result.stringValue = NSLocalizedString(@"", @"");
        } else if (status == canceled) {
            result.stringValue = NSLocalizedString(@"Canceled", @"");
            [result setTextColor:[NSColor redColor]];
        }  else if (status == done) {
            result.stringValue = NSLocalizedString(@"Done", @"");
            [result setTextColor:[NSColor greenColor]];
        }  else if (status == failed) {
            result.stringValue = NSLocalizedString(@"Failed", @"");
            [result setTextColor:[NSColor redColor]];
        }else if (status == decryption) {
            result.stringValue = NSLocalizedString(@"Decrypting", @"");
            [result setTextColor:[NSColor greenColor]];
        }  else if (status == deleting) {
            result.stringValue = NSLocalizedString(@"Deleting", @"");
            [result setTextColor:[NSColor greenColor]];
        }  else if (status == editPermission) {
            result.stringValue = NSLocalizedString(@"EditPermission", @"");
            [result setTextColor:[NSColor greenColor]];
        } else if (status == manuallyDelete) {
            result.stringValue = NSLocalizedString(@"Manual", @"");
            [result setTextColor:[NSColor greenColor]];
        }
        
        return result;
    } 
  else {
    NSTextField *result = [tableView makeViewWithIdentifier:@"ColumnTwo" owner:self];
    if (result == nil) {
        result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
        result.identifier = @"ColumnTwo";
    }
        [result setEditable:NO];
        [result setBordered:NO];
        [result setBackgroundColor:[NSColor clearColor]];
        return result;
    }
  }
     //NSLog(@"%d %ld\n",self.actionState, row);
    if (tableColumn == self.colEditPCheck) {
        NSButton *but = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 5, 5)];
        but.identifier = @"COne";
        [but setButtonType:NSSwitchButton];
        [but setTitle:@""];
        [but setTarget:self];
        [but setAction:@selector(checkSwitch:)];
        [but setTag:row];
        if ([[self.ArrCheckMarks objectAtIndex:row] integerValue])
        {
            [but setState:YES];
        }
        return but;
        
    } else if (tableColumn == self.colEditPContact) {
        //NSTextField *result = [tableView makeViewWithIdentifier:@"CTwo" owner:self];
        //if (result == nil) {
        NSTextField *result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 229, 51)];
        //result.identifier = @"CTwo";
        //}
        if (row < [self.arrayOfGroups count]) {
            result.stringValue = [[self.arrayOfGroups objectAtIndex:row] objectAtIndex:0];
        } else {
            //NSLog(@"%ld %ld\n",[self.arrayOfContacts count], row - [self.arrayOfGroups count]);
            
            result.stringValue = [[self.arrayOfContacts objectAtIndex:row - [self.arrayOfGroups count]] objectForKey:@"friendEmail"];
        }
        
        [result setBackgroundColor:[NSColor clearColor]];
        [result setBordered:NO];
        [result setEditable:NO];
        return result;
    }

}

- (BOOL)tableView:(NSTableView *)tableView shouldTypeSelectForEvent:(NSEvent *)event withCurrentSearchString:(NSString *)searchString {
    return false;
}

- (void)keyDown:(NSEvent *)theEvent {
    return;
}

-(void)checkSwitch:(id)sender
{
    int  row = [sender tag];
    
    int v = [[self.ArrCheckMarks objectAtIndex:row] integerValue];
    if(v) {
        [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:0]];
    } else {
        [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:1]];
    }
    
    if (self.preState != encrypt) {
        if([[self.ArrCheckMarks objectAtIndex:row] integerValue] != [[self.originCheckmark objectAtIndex:row] integerValue]) {
            [self.checkmarkChanges replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:1]];
        } else {
            [self.checkmarkChanges replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:0]];
        }
    }
}

-(void)deleteMember:(id)sender
{
    int  row = [sender tag];
    
    int v = [[self.ArrCheckMarks objectAtIndex:row] integerValue];
    if(v) {
        [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:0]];
    } else {
        [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:1]];
    }
}

-(void)checkSwitchContact:(id)sender
{
    int  row = [sender tag];
    
    int v = [[self.ArrCheckMarks objectAtIndex:row] integerValue];
    int count = 0;
    for (id checkmark in self.ArrCheckMarks) {
        if ([checkmark integerValue] == 1) {
            count += 1;
        }
    }
    
    if(v) {
        [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:0]];
        //[self.btnContactDelete setEnabled:NO];
        count -= 1;
    } else {
        [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:1]];
        //[self.btnContactDelete setEnabled:YES];
        count += 1;
    }
    if (count == 0) {
        [self.btnContactDelete setEnabled:NO];
    } 
    if (count == 1) {
        [self.btnContactDelete setEnabled:YES];
        [self.btnContactRename setEnabled:YES];
        [self.btnAddGroupMember setEnabled:YES];
    }
    if (count > 1) {
        [self.btnContactDelete setEnabled:YES];
        [self.btnContactRename setEnabled:NO];
        [self.btnAddGroupMember setEnabled:NO];
    }
    //[self.tbEditPermission reloadData];
}

-(void)deleteGroupMemberBuildRequest:(NSString *)friendName inGroup:(NSString *)groupName
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", friendName, @"\n", groupName, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api removeGroupMember:encodedGetParam target:(id)self selector:@selector(deleteGroupMemberResult:)];
}

-(void)deleteGroupMemberResult:(NSDictionary*)obj {
    self.actionState == noOperation;
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        return;

        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        //nslog(@"ContactView deleteGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
    
                [[self.arrayOfGroups objectAtIndex:self.selectedGroup] removeObjectAtIndex:self.memberDeleteIndex];
                self.startLoadMember = true;
                [self.tbMembers reloadData];
                return;
            }
                break;
            case GROUP_NOT_FOUND:
            {
                //[wv show:NSLocalizedString(@"GroupNameNotFoundKey", @"") inView:self.view];
                return;
            }
            case MEMBER_NOT_EXIST:
            {
                //[wv show:NSLocalizedString(@"GroupMemberNotExistKey", @"") inView:self.view];
                return;
            }
                break;
            default: {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
                [alert runModal];
            }
                break;
        }
        
    }
    
    //if ([obj objectForKey:@"httpErrorCode"] != nil)
        //nslog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    

    //[wv show:NSLocalizedString(@"RemoveGroupUnknownErrorKey", @"") inView:self.view];
}

-(void)memberDelete:(id)sender
{
    int  row = [sender tag];
    self.memberDeleteIndex = row + 1;
    NSMutableArray *group = [self.arrayOfGroups objectAtIndex:self.selectedGroup];
    [self deleteGroupMemberBuildRequest:[[group objectAtIndex:row + 1] objectForKey:@"friendEmail" ] inGroup:[group objectAtIndex:0]];
}

- (void)includeSwitch:(id)sender
{
    self.onTheFront = YES;
    int  row = [sender tag];
    
    int op = [[self.btnStatus objectAtIndex:row] integerValue];
    int status = [[self.opStatus objectAtIndex:row] integerValue];
    if (status != done) {
        if (op == include) {
            [self.btnStatus replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:exclude]];
            [self.opStatus replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt: noOperation]];
            if(self.actionState == encrypt) {
                [self.btnEncrypt setEnabled:YES];
            }else if(self.actionState == decrypt) {
                [self.btnDecrypt setEnabled:YES];
            }else if(self.actionState == editPermission) {
                [self.btnDecrypt setEnabled:YES];
            } 
    
        if([self.paths count] == 1) {
           if(self.firstFileType == usav) {
             [self.btnEncrypt setEnabled:NO];
             [self.btnEditPermission setEnabled:YES];
             [self.btnDecrypt setEnabled:YES];
             [self.btnHistory setEnabled:YES];
             [self.btnDelete setEnabled:YES];
           } else {
             [self.btnEncrypt setEnabled:YES];
             [self.btnEditPermission setEnabled:NO];
             [self.btnDecrypt setEnabled:NO];
             [self.btnHistory setEnabled:NO];
             [self.btnDelete setEnabled:NO];
           }
        }
        } else if (op == exclude) {
            [self.btnStatus replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:include]];
            [self.opStatus replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:canceled]];
            if([self.paths count] == 1) {
                [self.btnEncrypt setEnabled:NO];
                [self.btnEditPermission setEnabled:NO];
                [self.btnDecrypt setEnabled:NO];
                [self.btnHistory setEnabled:NO];
                [self.btnDelete setEnabled:NO];
            } 
        }
    }
    
    
    [self.tbFileAndDir reloadData];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20;
}
                                                                                                                                                                                                                             
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    if (self.loadNothing) {
        return [self.arrayOfGroups count] + [self.arrayOfContacts count];
    }
    else if (self.startLoadMember) {
        return [[self.arrayOfGroups objectAtIndex:self.selectedGroup] count];
    }else if (self.actionState == editPermission || self.actionState == editContact) {
        return [self.arrayOfGroups count] + [self.arrayOfContacts count];
    }else if (self.actionState == history) {
        return [self.logList count];
    }else {
        return self.numOfRow;
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    [[USAVLock defaultLock] setMainWindowOpenOff];
}

- (void)selectFileInFinder{
    NSString *filefullpath= [self.paths objectAtIndex:[self.tbFileAndDir clickedRow]];
    NSString *root = [filefullpath stringByDeletingLastPathComponent];
    
    [[NSWorkspace sharedWorkspace] selectFile:filefullpath inFileViewerRootedAtPath:root];
}

- (void) changeCheckMarks {
    self.loadNothing = NO;
    self.startLoadMember = NO;
    int row = [self.tbEditPermission clickedRow];
    
    if(![self.scrollViewGroupAndContacts isHidden]) {
    int v = [[self.ArrCheckMarks objectAtIndex:row] integerValue];
        
    if(v) {
        [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:0]];
    } else {
        [self.ArrCheckMarks replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:1]];
    }
        [self.tbEditPermission reloadData];
        
        if (self.preState != encrypt) {
            if([[self.ArrCheckMarks objectAtIndex:row] integerValue] != [[self.originCheckmark objectAtIndex:row] integerValue]) {
                [self.checkmarkChanges replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:1]];
            } else {
                [self.checkmarkChanges replaceObjectAtIndex:row withObject:[[NSNumber alloc] initWithInt:0]];
            }
        }
    }
    /*
    if (self.lastActionState != encrypt) {
        [self.checkmarkChanges objectAtIndex:v];
    }
    */
    
}

- (void)enableContact:(NSTimer*)theTimer {
    if([self.btnEditPermission isEnabled] || [self.btnEncrypt isEnabled]) {
        return;
    }
    if (![self.btnCancel isEnabled]) {
        [self.btnContactList setEnabled:YES];
    }
}

- (void)enableEditpermission:(NSTimer*)theTimer {
    [self.btnEditPermission setEnabled:YES];
}

- (void)boundDidChange:(NSNotification *)notification {
    self.loadNothing = NO;
    self.startLoadMember = NO;
}

- (void)superReload:(NSTimer*)theTimer {
    inLoadingContactList = NO;
}

- (void)windowDidLoad
{
    self.bar = [[NSProgressIndicator alloc] initWithFrame:CGRectMake(170, 300, 200, 50)];
    
    [self.bar setStyle:NSProgressIndicatorSpinningStyle];
    [self.view addSubview:self.bar];
    [self.bar setHidden:YES];
    
    self.txtVersionNumber.stringValue = @"v1.0";
    
    self.groupReady = NO;
    self.fileManager = [NSFileManager defaultManager];
    
    [self.tbEditPermission setPostsBoundsChangedNotifications:YES];
    //[[NSNotificationCenter defaultCenter] pri
    //S[[NSNotificationCenter defaultCenter] setPriority:1];
    // a register for those notifications on the content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boundDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:self.tbEditPermission];
    
    [self.tbContacts setPostsBoundsChangedNotifications:YES];
    
    // a register for those notifications on the content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boundDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:self.tbContacts];
    
    [self performSelector:@selector(enableContact:) withObject:nil afterDelay:6.0];
    
    self.rowindex = -1;
    self.selectedGroup = -1;
    self.contactReady = false;
    //[self listTrustedContactStatus];
    [self.scrollViewGroupAndContacts setHidden:YES];
    [self.scrollViewMembers setHidden:YES];
    
    self.keyIndex = 0;
    self.useDefaultOutputPath = false;
    self.basketEmpty = true;
    self.numOfRow = 0;
    
    [super windowDidLoad];
    [self.tbHistory setDelegate:self];
    [self.tbHistory setDataSource:self];
    [self.tbFileAndDir setDelegate:self];
    [self.tbFileAndDir setDataSource:self];
    
    [self.tbEditPermission setDelegate:self];
    [self.tbEditPermission setDataSource:self];
    
    [self.tbMembers setDelegate:self];
    [self.tbMembers setDataSource:self];
    [self.tbEditContact setDelegate:self];
    [self.tbEditContact setDataSource:self];
    
    [self.tbFileAndDir setDoubleAction:@selector(selectFileInFinder)];
    [self.tbEditPermission setDoubleAction:@selector(changeCheckMarks)];
    
    [self.btnCancel setTitle:NSLocalizedString(@"btnCancel", @"")];
    [self.btnDecrypt setTitle:NSLocalizedString(@"btnDecrypt", @"")];
    [self.btnDelete setTitle:NSLocalizedString(@"btnDelete", @"")];
    [self.btnEditPermission setTitle:NSLocalizedString(@"btnEditPermission", @"")];
    [self.btnEncrypt setTitle:NSLocalizedString(@"btnEncrypt", @"")];
    [self.btnHistory setTitle:NSLocalizedString(@"btnHistory", @"")];
    
    self.arrayOfGroups = [[NSMutableArray alloc] initWithCapacity:0];
    self.arrayOfContacts = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.window setTitle:NSLocalizedString(@"UsavWorkingWindow", @"")];
    [self.window registerForDraggedTypes: [NSArray arrayWithObjects: NSFilenamesPboardType, nil]];
    
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"", @"")]];
    [self checkUpdates];
}

-(void) createKeyBuildRequest
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", @"\n", [NSString stringWithFormat:@"%i", 256], @"\n"];
    
    ////nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    ////nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"size" stringValue:@"256"];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"meta1" stringValue:nil];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"meta2" stringValue:nil];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    ////nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api createKey:encodedGetParam target:(id)self selector:@selector(createKeyResult:)];
}


-(void) createKeyResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:failed]];
        
        if(self.firstFileType != plain) {[self.btnDecrypt setEnabled:YES];}
        
        tempAcc  += 1;
        if(tempAcc <= 1) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
            [alert runModal];
        }
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:failed]];
        
        if(self.firstFileType != plain) {[self.btnDecrypt setEnabled:YES];}
        
        
        tempAcc  += 1;
        if(tempAcc <= 1) {
            [self.tbFileAndDir reloadData];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
            [alert runModal];
           
        }
        return;
    }

	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        ////nslog(@"%@ createKeyResult: %@", [self class], obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                
                NSArray *key = [NSArray arrayWithObjects:keyId, keyContent, nil];
                [self.keyPool addObject:key];
                
                int keySize = [[obj objectForKey:@"Size"] integerValue];
                return;
            }
                break;
            case INVALID_KEY_SIZE:
            {
                
                return;
            }
                break;
            default: {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
                [alert runModal];
            }
                break;
        }
        
    }
}

-(void) createKeyBuildRequestForRemainder
{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", @"\n", [NSString stringWithFormat:@"%i", 256], @"\n"];
    
    ////nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    ////nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"size" stringValue:@"256"];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"meta1" stringValue:nil];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"meta2" stringValue:nil];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    ////nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api createKey:encodedGetParam target:(id)self selector:@selector(createKeyResultRemainder:)];
}


-(void) createKeyResultRemainder:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        return;
    }
    
    if (obj == nil) {
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        ////nslog(@"%@ createKeyResult: %@", [self class], obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                NSData *keyId = [NSData dataFromBase64String:[obj objectForKey:@"Id"]];
                NSData *keyContent = [NSData dataFromBase64String:[obj objectForKey:@"Content"]];
                
                NSArray *key = [NSArray arrayWithObjects:keyId, keyContent, nil];
                [self.keyRemainedPool addObject:key];
                
                int keySize = [[obj objectForKey:@"Size"] integerValue];
                return;
            }
                break;
            case INVALID_KEY_SIZE:
            {
                return;
            }
                break;
            default: {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
                [alert runModal];
            }
                break;
        }
        
    }
}

- (IBAction)btnEncryptPressed:(id)sender {
    [self.bar setHidden:NO];
    [self.bar startAnimation:nil];
    
    self.preState = encrypt;
    
    self.lastActionState = encrypt;
    
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"Encrypt", @"")]];
    
    [self.btnContactList setEnabled:NO];

    self.actionState = encrypt;
    self.actionStart = YES;
    [self.btnEncrypt setEnabled:NO];
    
    int keyPoolNum = [self.keyPool count] + [self.keyRemainedPool count];
    int needed = [self howManyKeyNeeded: self.btnStatus];
    int numOfRemainder = needed - keyPoolNum;
    if (numOfRemainder > 0) {
        //[self.keyRemainedPool removeAllObjects];
        [self getRemainedKeys:numOfRemainder];
    }
    
    int encryptAttempts = 0;
    int encryptSucceed = 0;
    
    //start encrypting
    int i = 0;
    for (int j = 0; j < [self.paths count]; j++) {
        NSString *path = [self.paths objectAtIndex:j];
        if ([[self.opStatus objectAtIndex:i] integerValue] != done && [[self.btnStatus objectAtIndex:i] integerValue] == exclude) {
            
            encryptAttempts += 1;
        
            [self.opStatus replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:encrypting]];
            [self.tbFileAndDir reloadData];
            NSArray *key;
            if (i < [self.keyPool count]) {
                key = [self.keyPool objectAtIndex:i];
            } else {
                int numOfKey = [self.keyRemainedPool count];
                if (!numOfKey) {
                    //[self.CancelButton setHidden:NO];
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:NSLocalizedString(@"ErrorNoKey", @"")];
                    [alert runModal];

                    [self.opStatus replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:failed]];
                    [self.tbFileAndDir reloadData];
                    [self.btnEncrypt setEnabled:YES];
                    [self.bar setHidden:YES];
                    [self.bar stopAnimation:nil];
                    return; 
                }
                int iInRange = i % [self.keyRemainedPool count];
                key = [self.keyRemainedPool objectAtIndex: iInRange];
                [self.keyRemainedPool removeObjectAtIndex:iInRange];
            }
            
            if([self encryptSingleFile:path withKey:key]) {
                //change the name in path list
                //chage the name in file name list
                //NSString *outputName = [NSString stringWithFormat:@"%@%@", path, @".usav"];
                [self.paths replaceObjectAtIndex:i withObject:self.tmp_filepath];
                [self.fileNames replaceObjectAtIndex:i withObject:[self.tmp_filepath lastPathComponent]];
                
                [self.opStatus replaceObjectAtIndex:i withObject:[[NSNumber alloc] initWithInt:done]];
                [self.btnEditPermission setEnabled:YES];
                encryptSucceed += 1;
                [self.usedKeys addObject:[key objectAtIndex:0]];
                //self.firstFileType = usav;
            }
        [self.tbFileAndDir reloadData];
        }
        i += 1;
        
    }
    
    if (encryptSucceed == encryptAttempts) {
        [self.btnCancel setTitle:NSLocalizedString(@"Done", @"")];
        [self.tbFileAndDir reloadData];
    } else {
        [self.btnEncrypt setEnabled:YES];
    }
    //[self.progressBar stopAnimation:nil];
    //[self.progressBar setHidden:YES];
    [self.bar stopAnimation:nil];
    [self.bar setHidden:YES];
}

- (BOOL)encryptSingleFile:(NSString *)ofile withKey:(NSArray *) key {
    NSString *path = [ofile stringByDeletingLastPathComponent];
    NSString *filename = [ofile lastPathComponent];
    
    NSString *defaultOutputRoot;
    if(self.useDefaultOutputPath) {
        defaultOutputRoot = self.defaultEncryptOutputPath;
    }
    
    if (!key) {
        return false;
    }
    NSString *extension = [filename pathExtension];
    //NSString *outputFilename = [self filenameConflictSovlerForEncrypt:[components lastObject] forPath:self.encryptPath];
    filename = [self filenameConflictSovlerForEncrypt:filename forPath:path];
  
    NSString *tempFullPath = [NSString stringWithFormat:@"%@/%@%@", path, filename, @".-temp"];
    
    NSString *targetFullPath = [NSString stringWithFormat:@"%@/%@", path,filename];
    self.tmp_filepath = tempFullPath;
    
    //BOOL rc = [[UsavCipher defualtCipher] encryptFile:self.currentFullPath targetFile:targetFullPath keyID:keyId //keyContent:keyContent];
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have entered an incorrect passcode too many times. All account data in this app has been deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alert show];*/
    BOOL rc;
    @try {
        //rc = [[UsavStreamCipher defualtCipher] encryptFile:ofile targetFile:tempFullPath keyID:[key objectAtIndex:0] ////keyContent:[key objectAtIndex:1]];
        rc = [[UsavStreamCipher defualtCipher] encryptFile:ofile  targetFile:tempFullPath keyID:[key objectAtIndex:0]  keyContent:[key objectAtIndex:1] withExtension:extension andMinversion:4];
        
        self.tmp_filepath = targetFullPath;
    }
    
    @catch (NSException *exception) {
        return false;
    }
    
    if (rc == 0 || rc == true) {
        [[NSFileManager defaultManager] moveItemAtPath:tempFullPath toPath:targetFullPath error:nil];
        return true;
    }
    
    return rc;
}

- (int)howManyKeyNeeded:(NSMutableArray *)statusList {
    int num = 2;
    for (id status in statusList) {
        if ([status isEqualToNumber:[[NSNumber alloc] initWithInt:exclude]]) {
            num += 1;
        }
    }
    return num;
}

- (void)getRemainedKeys:(int)knum {
        //get more keys than need
    tempAcc = 0;
    knum += keyBufferSize;
    while(knum--) {
        [self createKeyBuildRequestForRemainder];
    }
}

- (IBAction)deletePressed:(id)sender {

 
    
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"Delete", @"")]];
    
    self.actionStart = YES;
    self.keyIndex = 0;
    self.actionState = delete;
    [self determineBtnStateBy:self.actionState];
    
    self.keyIndex = [self chooseAvailableItemStartFrom:self.keyIndex];
    if (self.keyIndex == -1) {
        //[self determineBtnStateBy:decrypt];
        return;
    }
    
    self.currentPath = [self.paths objectAtIndex:self.keyIndex];
    [self deleteKeyBuildRequest:self.currentPath];
}

- (BOOL) deleteFileAtCurrentPath:(NSString *)path {
    
}

-(void) deleteKeyResult:(NSDictionary*)obj {
    //[self deleteFileAtCurrentFullPath];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
            [alert runModal];
        
            [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:failed]];
            [self.tbFileAndDir reloadData];
        
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        
        [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:failed]];
        [self.tbFileAndDir reloadData];
        //[self enalbeButtonForUsavFiles];
        

        return;
    }
     if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
     //nslog(@"%@ deleteKeyResult: %@", [self class], obj);
     
     int rc;
     if ([obj objectForKey:@"statusCode"] != nil)
     rc = [[obj objectForKey:@"statusCode"] integerValue];
     else
     rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
     
     switch (rc) {
     case SUCCESS:
     {
        [self.tbFileAndDir reloadData];
        NSError *ferror = nil;

        BOOL frc;
        frc = [[NSFileManager defaultManager] removeItemAtPath:[self.paths objectAtIndex:self.keyIndex] error:&ferror];
        if (frc == YES) {
            [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:done]];
        } else {
            [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:manuallyDelete]];
        }

        self.keyIndex += 1;
         
         self.keyIndex = [self chooseAvailableItemStartFrom:self.keyIndex];
         if (self.keyIndex == -1) {
             //[self determineBtnStateBy:decrypt];
             return;
         } else {
             [self deleteKeyBuildRequest:[self.paths objectAtIndex:self.keyIndex]];
         }

         //[self deleteFileAtCurrentPath];
         return;
     }
     break;
     case KEY_NOT_FOUND:
     {
         NSAlert *alert = [[NSAlert alloc] init];
         [alert setMessageText:NSLocalizedString(@"Key not found", @"")];
         [alert runModal];
     return;
     }
     break;
     default:
    { [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:failed]]; [self.tbFileAndDir reloadData];}
             NSAlert *alert = [[NSAlert alloc] init];
             [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
             [alert runModal];
     break;
     }
     
     }
        
     //if ([obj objectForKey:@"httpErrorCode"] != nil)
     //nslog(@"%@ deleteKeyResult httpErrorCode: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
}

- (void) deleteKeyBuildRequest:(NSString *)path
{
    tempAcc = 1;
    
    [self.opStatus replaceObjectAtIndex:self.keyIndex withObject:[[NSNumber alloc] initWithInt:deleting]];
    [self.tbFileAndDir reloadData];

    
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:path];
    
    NSString *keyIdString = [keyId base64EncodedString];
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", keyIdString, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyIdString];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api deleteKey:encodedGetParam target:(id)self selector:@selector(deleteKeyResult:)];
}

-(void)listGroup
{
    if (!firstLoad) {
    [self.bar setHidden:NO];
    [self.bar startAnimation:nil];
    }
    inLoadingContactList = YES;
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listGroup:encodedGetParam target:(id)self selector:@selector(listGroupResult:)];
}

-(void) listGroupResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        inLoadingContactList = NO;
        firstLoad = 0;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        inLoadingContactList = NO;
        firstLoad = 0;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        return;
    }

	if (obj != nil) {
        //NSLog(@"%@ original array: %@", [self class], self.arrayOfGroups);
        
        if(self.groupReady) return;
        
        if (([obj objectForKey:@"groupList"] != nil) && ([[obj objectForKey:@"groupList"] count] >= 0)) {
            NSArray *groups = [obj objectForKey:@"groupList"];
            for (int i = 0; i < [groups count]; i++) {
                NSMutableArray *groupAndItsMember = [NSMutableArray arrayWithCapacity:0];
                [groupAndItsMember addObject:[groups objectAtIndex:i]];
                [self.arrayOfGroups addObject:groupAndItsMember];
            }
        
        self.groupReady = YES;
        self.arrayOfGroups = [NSMutableArray arrayWithArray:[[NSSet setWithArray: self.arrayOfGroups] allObjects]];
        //NSLog(@"%@ array from set: %@", [self class], self.arrayOfGroups);

            if (![groups count]) {
                if(self.actionState != editPermission ) {
                    if(self.actionState != editPermission ) {
                        if(![self.btnEditPermission isEnabled] && ![self.btnEncrypt isEnabled]) {
                            [self.btnContactList setEnabled:YES];
                        }
                    }
                }
                self.contactReady = YES;
                for (int i = 0; i < [self.arrayOfGroups count]; i++) {
                    [self.ArrCheckMarks addObject:[[NSNumber alloc] initWithInt:0]];
                }
                for (int i = 0; i < [self.arrayOfContacts count]; i++) {
                    [self.ArrCheckMarks addObject:[[NSNumber alloc] initWithInt:0]];
                }
                if (self.actionState == editPermission) {
                    [self.tbEditPermission reloadData];
                } else if (self.actionState == editContact) {
                    [self.tbEditContact reloadData];
                }
                firstLoad = 0;
                [self.bar setHidden:YES];
                [self.bar stopAnimation:nil];
                inLoadingContactList = NO;
            }else {
                [self listGroupMemberStatus:[[self.arrayOfGroups objectAtIndex:self.groupIndex] objectAtIndex:0]];
            }
            //[self.bar setHidden:YES];
            //[self.bar stopAnimation:nil];
            self.groupIndex = 0;
        }
    } else {
         firstLoad = 0;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        inLoadingContactList = NO;
    }
}

-(void)listTrustedContactStatus
{
    if (!firstLoad) {
        [self.bar setHidden:NO];
        [self.bar startAnimation:nil];
    }
    inLoadingContactList = YES;
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listTrustedContactStatus:encodedGetParam target:(id)self selector:@selector(listTrustedContactStatusResult:)];
}

-(NSString *)filenameConflictSovlerForDecrypt:(NSString *)newFile forPath:(NSString *)path

{
    //newly added file's property
    NSString *newFilesExtension = [newFile pathExtension];
    NSString *newFileNameWithOutExtension = [newFile stringByDeletingPathExtension];
    if ([newFileNameWithOutExtension length] >= 3) {
        NSRange indexRange2 = {[newFileNameWithOutExtension length] -  3, 3};
        //[existedFilesNameWithOutExtension getCharacters:threeChar range:indexRange];
        
        //check if it is a "()"
        NSString *lastThreeChars = [newFileNameWithOutExtension substringWithRange:indexRange2];
        
        if ([lastThreeChars characterAtIndex:0] == '(') {
            NSRange withoutThree = {0,[newFileNameWithOutExtension length] - 3};
            newFileNameWithOutExtension = [newFileNameWithOutExtension substringWithRange:withoutThree];
        }
    }
    //file already in the folder
    
    NSString *existedFilesExtension; //This should be uSav
    NSString *existedFilesOriginExtension;
    NSString *existedFilesNameWithOutExtension;
    
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    int numAllfile = [allFile count];
    
    int postFix = 0;
    BOOL firstTime = true;
    
    for (int i = 0; i < numAllfile; i++) {
        //Get one file's full name
        NSString *singleFile = [allFile objectAtIndex:i];
        
        //existedFilesExtension = [singleFile pathExtension];
        existedFilesOriginExtension = [singleFile pathExtension];
        existedFilesNameWithOutExtension = [singleFile stringByDeletingPathExtension];
        
        NSString *potentialThreeChars;
        if ([existedFilesNameWithOutExtension length] >= 3) {
            NSRange indexRange = {[existedFilesNameWithOutExtension length] - 3, 3};
            potentialThreeChars = [existedFilesNameWithOutExtension substringWithRange:indexRange];
        }
        
        if (![existedFilesOriginExtension isEqualToString:newFilesExtension]) {
            //if no extension conflict then check next item
            continue;
        }
        
        if ([potentialThreeChars characterAtIndex:0] == '(') {
            NSRange withoutThree = {0,[existedFilesNameWithOutExtension length] - 3};
            if (![[existedFilesNameWithOutExtension substringWithRange:withoutThree] isEqualToString: newFileNameWithOutExtension])
                //if no file name conflict then check next item
                continue;
        } else if (![existedFilesNameWithOutExtension isEqualToString:newFileNameWithOutExtension]) {
            continue;
        }
        
        if ([potentialThreeChars characterAtIndex:0] == '(') {
            NSArray *removeClouse = [potentialThreeChars componentsSeparatedByString:@"("];
            int fileIndex = [[[[removeClouse objectAtIndex:1] componentsSeparatedByString:@"("] objectAtIndex:0] intValue];
            if (fileIndex >= postFix) {
                postFix  = fileIndex + 1;
            }
        } else if(firstTime){
            postFix = 1;
        }
        firstTime = false;
    }
    
    if (postFix == 0) {
        return [NSString stringWithFormat:@"%@", newFile];
    } else {
        return [NSString stringWithFormat:@"%@%@%d%@%@", newFileNameWithOutExtension, @"(", postFix, @").", newFilesExtension];
    }
}


-(void)listTrustedContactStatusResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        inLoadingContactList = NO;
        firstLoad = 0;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260)
    {
        tempAcc += 1;
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        inLoadingContactList = NO;
         firstLoad = 0;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        return;
    }
    
 	if (obj != nil) {
        /*if (self.preState == encrypt) {
            [self.scrollViewMain setHidden:YES];
            [self.scrollViewMembers setHidden:NO];
            [self.scrollViewGroupAndContacts setHidden:NO];
            self.actionState = editPermission;
        
            [self determineBtnStateBy: self.actionState];
            [self.txtTileMain setStringValue:NSLocalizedString(@"     Edit Permission", @"")];
            [self.txtTileSub setStringValue:NSLocalizedString(@"", @"")];
        }*/
        if (([obj objectForKey:@"contactList"] != nil) && ([[obj objectForKey:@"contactList"] count] > 0)){
            [self.arrayOfContacts addObjectsFromArray:[obj objectForKey:@"contactList"]];
            self.arrayOfContacts = [NSMutableArray arrayWithArray:[[NSSet setWithArray: self.arrayOfContacts] allObjects]];
            [self listGroup];
        } else if ([[obj objectForKey:@"contactList"] count] == 0) {
            [self listGroup];
        } else {
             firstLoad = 0;
            [self.bar setHidden:YES];
            [self.bar stopAnimation:nil];
            inLoadingContactList = NO;
        }
    }
    else {
         firstLoad = 0;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        inLoadingContactList = NO;
    }
}

-(void)listGroupMemberStatus:(NSString *)groupId
{
    if (!firstLoad) {
        [self.bar setHidden:NO];
        [self.bar startAnimation:nil];
    }

    inLoadingContactList = YES;
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupId, @"\n"];
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listGroupMemberStatus:encodedGetParam target:(id)self selector:@selector(listGroupMemberStatusResult:)];
}

-(void) listGroupMemberStatusResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
         firstLoad = 0;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        inLoadingContactList = NO;
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260){
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
         firstLoad = 0;
        inLoadingContactList = NO;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"contactList"] != nil)) {
        if ([[self.arrayOfGroups objectAtIndex:self.groupIndex] count] < 2) {
            [[self.arrayOfGroups objectAtIndex:self.groupIndex] addObjectsFromArray:[obj objectForKey:@"contactList"]];
        }
        
        self.groupIndex += 1;
        if (self.groupIndex >= [self.arrayOfGroups count]) {
            if(self.actionState != editPermission ) {
                if(![self.btnEditPermission isEnabled] && ![self.btnEncrypt isEnabled]) {
                    [self.btnContactList setEnabled:YES];
                }
            }
            self.contactReady = YES;
            for (int i = 0; i < [self.arrayOfGroups count]; i++) {
                [self.ArrCheckMarks addObject:[[NSNumber alloc] initWithInt:0]];
            }
            for (int i = 0; i < [self.arrayOfContacts count]; i++) {
                [self.ArrCheckMarks addObject:[[NSNumber alloc] initWithInt:0]];
            }
            if (self.actionState == editPermission) {
                [self.tbEditPermission reloadData];
            } else if (self.actionState == editContact) {
                [self.tbEditContact reloadData];
            }
            inLoadingContactList = NO;
            [self.bar setHidden:YES];
            [self.bar stopAnimation:nil];
             firstLoad = 0;
            return;
            
        } else {
            [self listGroupMemberStatus:[[self.arrayOfGroups objectAtIndex:self.groupIndex] objectAtIndex:0]];
        }
    }
    else {
         firstLoad = 0;
        [self.bar setHidden:YES];
        [self.bar stopAnimation:nil];
        inLoadingContactList = NO;
    }
}



- (void)setPermissionMono:(NSString *)keyId for:(NSString *)name isUser:(int)isUser withPermission:(int)permission
{
    USAVClient *client = [USAVClient current];
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",[[NSString alloc] initWithFormat:@"%d",isUser], @"\n", keyId, @"\n",
                                name, @"\n", [[NSString alloc] initWithFormat:@"%d", permission]];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyId];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"name" stringValue:name];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"isUser" stringValue:[[NSString alloc] initWithFormat:@"%d", isUser]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"permission" stringValue:[[NSString alloc] initWithFormat:@"%d",permission]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api setFriendListPermision:encodedGetParam target:(id)self selector:@selector(setPermissionCallBack:)];
}

- (void)cancelEditpermission {
    self.actionState = editPermission2;
    [self cancelPressed:nil];
}

- (NSString *)input3: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel operation"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    
    [alert setAccessoryView:input];
    [input setHidden:YES];
    
    
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        self.actionState = editPermission2;
        [self cancelPressed:nil];
    } else {
        NSAssert1(NO, @"Invalid input dialog button %d", button);
        return nil;
    }
}

- (void)setPermissionCallBack:(NSDictionary*)obj
{
    if (obj == nil) {
        [self.btnCancel setEnabled:YES];
        tempAcc  += 1;
        if(tempAcc <= 1) {
            [self.tbFileAndDir reloadData];
            
            NSButton *but = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 5, 5)];
            NSAlert *alert =  [NSAlert alertWithMessageText:NSLocalizedString(@"TimeStampError", @"") defaultButton:NSLocalizedString(@"OK", @"")alternateButton:NSLocalizedString(@"OK", @"") otherButton:nil informativeTextWithFormat:@"bbb"];
            
            [self input3:NSLocalizedString(@"TimeStampError", @"") defaultValue:@"All"];
            
            /*
            [but setTarget:self];
            [but setAction:@selector(cancelEditpermission:)];*/
            /*NSInteger button = [alert runModal];
            if (button == NSAlertDefaultReturn) {
                //[input validateEditing];
                //return [input stringValue];
            } else if (button == NSAlertAlternateReturn) {
               // return nil;
            } else {
               // NSAssert1(NO, @"Invalid input dialog button %d", button);
                //return nil;
            }
            */
            //[alert runModal];
            self.preState = encrypt;
        }
        return;
    }
    
    if ((obj != nil) && ([[obj objectForKey:@"rawStringStatus"] integerValue] == 0)) {
        self.actionState = editPermission2;
        self.successPermissions += 1;
        if (self.successPermissions == aimedPermissions / 2 + 1) {
            self.onTheFront = YES;
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"SetPermissionSuccess", @"")];
            [alert runModal];
            [self.btnCancel setEnabled:FALSE];
            [self cancelPressed:nil];
            
        }
        //self.successPermissions += 1;
        /*if (self.successPermissions == self.aimedPermissions) {
            self.actionState = editPermission2;
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"SetPermissionSuccess", @"")];
            [alert runModal];
            [self cancelPressed:nil];
        }*/
    } else {
            self.successPermissions += 1;
            if (self.successPermissions == aimedPermissions / 2 + 1) {
                self.actionState = editPermission2;

                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"SetPermissionFailed", @"")];
                [alert runModal];
                self.successPermissions = 0;
                [self cancelPressed:nil];
            }
    }
}

- (void)getPermissionForFile:(NSString *)filepath {
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:filepath];
    NSString *keyIdString = [keyId base64EncodedString];
    self.keyIdString = keyIdString;
    
    [self getPermissionList:keyIdString];
    
}

- (void)getPermissionList:(NSString *)keyId
{
    USAVClient *client = [USAVClient current];
    NSString * subParameters = [NSString stringWithFormat:@"%@", keyId];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n",
                              subParameters, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyId];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listFriendListPermision:encodedGetParam target:(id)self selector:@selector(getPermissionListCallBack:)];
}

- (void)getPermissionListCallBack:(NSDictionary*)obj
{
    //[self.alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //if failed show editPermission failed
    
    //else if success number < target number
    //accumulate success number
    //else if success number == target number
    //show success message then dissmiss the view
    if (obj == 0 || [[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        if(tempAcc == 0) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
            [alert runModal];
        }
        return;
    }
    
    if ((obj != nil) && ([[obj objectForKey:@"statusCode"] integerValue] == 0)) {
        [self.scrollViewMain setHidden:YES];
        [self.scrollViewMembers setHidden:NO];
        [self.scrollViewGroupAndContacts setHidden:NO];
        self.actionState = editPermission;
        
        [self determineBtnStateBy: self.actionState];
        [self.txtTileMain setStringValue:NSLocalizedString(@"     Edit Permission", @"")];
        [self.txtTileSub setStringValue:NSLocalizedString(@"", @"")];
        //[self performSegueWithIdentifier:@"EditPermission" sender:self];
        self.permissions = [obj objectForKey:@"permissionList"];
        for (int i = 0; i < [self.permissions count]; i++) {
            NSString *name = [[self.permissions objectAtIndex:i] objectForKey:@"name"];
            for(int j = 0; j < [self.arrayOfGroups count] + [self.arrayOfContacts count]; j++) {
                int nG = [self.arrayOfGroups count];
                if(j < nG) {
                    if([name isEqualToString:[[self.arrayOfGroups objectAtIndex:j] objectAtIndex:0]]) {
                        [self.ArrCheckMarks replaceObjectAtIndex:j withObject:[[NSNumber alloc] initWithInt:1]];
                    }
                }else {
                    
                    if([name isEqualToString:[[self.arrayOfContacts objectAtIndex:j - nG] objectForKey:@"friendEmail"]]) {
                        [self.ArrCheckMarks replaceObjectAtIndex:j withObject:[[NSNumber alloc] initWithInt:1]];
                    }
                }
            }
        }
        
        self.checkmarkChanges = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < [self.ArrCheckMarks count]; i++) {
            [self.checkmarkChanges addObject:[[NSNumber alloc] initWithInt:0]];
        }
        
        self.originCheckmark = [self.ArrCheckMarks copy];
        
        [self.tbEditPermission reloadData];
        
    }
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"PermissionDenied", @"")];
        [alert runModal];
    }
}

-(void) addGroupBuildRequest:(NSString *)groupName {
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupName, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api addGroup:encodedGetParam target:(id)self selector:@selector(addGroupResult:)];
}

-(void) addGroupResult:(NSDictionary*)obj {
    
    [self.tbMembers reloadData];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        return;
    }

	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        //nslog(@"ContactView addGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
            
                NSMutableArray *group = [[NSMutableArray alloc] initWithCapacity:0];
                [group addObject:self.groupName];
                [self.arrayOfGroups addObject:group];
                self.arrayOfGroups = [NSMutableArray arrayWithArray:[[NSSet setWithArray: self.arrayOfGroups] allObjects]];
            

                self.startLoadMember = false;
                self.actionState = editContact;
                [self.ArrCheckMarks insertObject:[[NSNumber alloc] initWithInt:0] atIndex:[self.arrayOfGroups count] - 1];
                [self.tbEditContact reloadData];
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Add Group Succeed!", @"")];
                [alert runModal];
                return;
            }
                break;
            case INVALID_GROUP_NAME:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"GroupNameInvalidKey", @"")];
                [alert runModal];
    
                return;
            }
                break;
            case GROUP_EXIST:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"GroupNameAlreadyExistKey", @"")];
                [alert runModal];

              
                return;
            }
                break;
            default: {
                
                break;
            }
        }
        
    }
    
    //if ([obj objectForKey:@"httpErrorCode"] != nil)
        //nslog(@"ContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
}

-(void)addFriendRequest:(NSString *)friendName {
    
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", @"\n", friendName, @"\n", @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:@""];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"note" stringValue:@""];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    /*
     paramElement = [GDataXMLNode elementWithName:@"alias" stringValue:aliasName];
     [paramsElement addChild:paramElement];
     paramElement = [GDataXMLNode elementWithName:@"email" stringValue:emailAddress];
     [paramsElement addChild:paramElement];
     */
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api addFriend:encodedGetParam target:(id)self selector:@selector(addFriendResult:)];
}

-(void) addFriendResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        return;
    }
 
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        //nslog(@"ContactView addGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {                
                NSMutableDictionary *friendDict = [NSMutableDictionary
                                                   dictionaryWithObjectsAndKeys:self.friendName,
                                                   @"friendEmail", @"", @"friendAlias", @"", @"friendNote", @"inactivated", @"friendStatus",nil];
                
                [self.arrayOfContacts addObject:friendDict];
                [self.ArrCheckMarks addObject:[[NSNumber alloc] initWithInt:0]];
                [self.tbEditContact reloadData];
                return;
            }
                break;
            case ACC_NOT_FOUND:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Account not found", @"")];
                [alert runModal];
                //[wv show:NSLocalizedString(@"ContactNameNotFoundKey", @"") inView:self.view];
                return;
            }
                break;
            case INVALID_FD_ALIAS:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"AliasNameInvalidKey", @"")];
                [alert runModal];
                return;
            }
                break;
            case INVALID_EMAIL:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"EmailNameInvalidKey", @"")];
                [alert runModal];
          
                return;
            }
                break;
            case FRIEND_EXIST:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"FriendNameAlreadyExistKey", @"")];
                [alert runModal];
               
                return;
            }
                break;
            default:
                break;
        }
    }
    
    if ([obj objectForKey:@"httpErrorCode"] != nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"AddFriendailed", @"")];
        [alert runModal];
    }

}


-(void)addGroupMember:(NSString *)groupStr forContact:(NSString *)friendEmail{
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", friendEmail, @"\n", groupStr, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupStr];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendEmail];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api addGroupMember:encodedGetParam target:(id)self selector:@selector(addGroupMemberResult:)];
}


-(void) addGroupMemberResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
                //[wv show:NSLocalizedString(@"TimeStampError", @"") inView:self.view];
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        //nslog(@"ContactView addGroupMemberResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                //[wv show:NSLocalizedString(@"AddMemberToGroupSuccessKey", @"") inView:self.view];
                NSMutableArray *group = [self.arrayOfGroups objectAtIndex:self.selectedGroup];
                
                NSMutableDictionary *friendDict = [NSMutableDictionary
                                                   dictionaryWithObjectsAndKeys:self.friendName,
                                                   @"friendEmail", @"", @"friendAlias", @"", @"friendNote", @"inactivated", @"friendStatus",nil];
                [group addObject:friendDict];
                self.startLoadMember = YES;
                [self.tbMembers reloadData];
                return;
            }
                break;
            case GROUP_NOT_FOUND:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"GroupNameNotFoundKey", @"")];
                [alert runModal];
    
                return;
            }
            case FRIEND_NOT_FOUND:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"GroupMemberNotExistKey", @"")];
                [alert runModal];
            
                return;
            }
                break;
            default: {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Error", @"")];
                [alert runModal];
            }
                break;
        }
    }
    //if ([obj objectForKey:@"httpErrorCode"] != nil)
        //nslog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
        //[wv show:NSLocalizedString(@"RemoveGroupUnknownErrorKey", @"") inView:self.view];
}

-(void) deleteGroupBuildRequest:(NSString *)groupName {
    accumulat = 1;
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", groupName, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"group" stringValue:groupName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api removeGroup:encodedGetParam target:(id)self selector:@selector(deleteGroupResult:)];
}

-(void) deleteGroupResult:(NSDictionary*)obj {
    accumulat = 0;
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        return;
    }
    
    if (obj == nil) {
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        //nslog(@"ContactView deleteGroupResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                [self.btnContactDelete setHidden:YES];
                [self.btnContactRename setHidden:YES];
                [self.btnAddGroupMember setHidden:YES];
                
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Delete Group Succeed!", @"")];
                [alert runModal];
                [self.arrayOfGroups removeObjectAtIndex:self.selectedGroup];
                [self.ArrCheckMarks removeObjectAtIndex:self.selectedGroup];
                [self.tbEditContact reloadData];
                self.clearMember = YES;
                [self.tbMembers reloadData];
                return;
            }
                break;
            case GROUP_NOT_FOUND:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"GroupNameNotFoundKey", @"")];
                [alert runModal];
             
                return;
            }
                break;
            default: {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Error", @"")];
                [alert runModal];
            }
                break;
        }
        
    }
    
    //if ([obj objectForKey:@"httpErrorCode"] != nil)
        //nslog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"RemoveGroupUnknownErrorKey", @"")];
    [alert runModal];
}

-(void) deleteContactBuildRequest:(NSString *)friendName {
     accumulat = 1;
    USAVClient *client = [USAVClient current];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", friendName, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"friendId" stringValue:friendName];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api deleteTrustContact:encodedGetParam target:(id)self selector:@selector(deleteContactResult:)];
}

-(void) deleteContactResult:(NSDictionary*)obj {
    accumulat = 0;
    [self.btnContactDelete setHidden:YES];
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        return;
    }
    
    if ([[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
      
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        return;
    }
    
    if (obj == nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"Timeout", @"")];
        [alert runModal];
            
        return;
    }
    
	if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
        //nslog(@"ContactView deleteContactResult: %@", obj);
        
        int rc;
        if ([obj objectForKey:@"statusCode"] != nil)
            rc = [[obj objectForKey:@"statusCode"] integerValue];
        else
            rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
        
        switch (rc) {
            case SUCCESS:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Delete contact succeed!", @"")];
                [alert runModal];
                int index = self.rowindex - [self.arrayOfGroups count];
                [self.arrayOfContacts removeObjectAtIndex:index];
                
                [self.ArrCheckMarks removeObjectAtIndex:self.rowindex];
                self.loadNothing = NO;
                self.startLoadMember = NO;
                [self.tbEditContact reloadData];
               
                // [self.arrayOfContacts addObject:friendDict];
                              return;
            }
                break;
            case FRIEND_NOT_FOUND:
            {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"ContactNameNotFoundKey!", @"")];
                [alert runModal];
                //[wv show:NSLocalizedString(@"ContactNameNotFoundKey", @"") inView:self.view];
                return;
            }
                break;
            default: {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"Error", @"")];
                [alert runModal];
            }
                break;
        }
    }
    
    //if ([obj objectForKey:@"httpErrorCode"] != nil)
        //nslog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"DeleteTrustContactUnknownErrorKey!", @"")];
    [alert runModal];
}

-(void) editGroupNameFrom:(NSString *)oldname to: (NSString *)newname{
            
    USAVClient *client = [USAVClient current];
             
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@", newname, @"\n", oldname];
             
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
             
    //nslog(@"stringToSign: %@", stringToSign);
             
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
             
    //nslog(@"signature: %@", signature);
             
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
             
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"oldname" stringValue:oldname];
    [paramsElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"newname" stringValue:newname];
    [paramsElement addChild:paramElement];
             
    [requestElement addChild:paramsElement];
             
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
             
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
             
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
             
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
             
    [client.api editGroupName:encodedGetParam target:(id)self selector:@selector(editGroupNameResult:)];
}
         
-(void) editGroupNameResult:(NSDictionary*)obj {
    [self.btnContactDelete setHidden:YES];
    [self.btnContactRename setHidden:YES];
    [self.btnAddGroupMember setHidden:YES];
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        return;
    }
    
    if (obj == nil || [[obj objectForKey:@"rawStringStatus"] integerValue] == 261 || [[obj objectForKey:@"rawStringStatus"] integerValue] == 260) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        return;
        
    }
    
             if (obj == nil) {
      
                 NSAlert *alert = [[NSAlert alloc] init];
                 [alert setMessageText:NSLocalizedString(@"Timeout", @"")];
                 [alert runModal];
                 return;
             }
             
             if ((obj != nil) && ([obj objectForKey:@"httpErrorCode"] == nil)) {
                 //nslog(@"ContactView deleteContactResult: %@", obj);
                 
                 int rc;
                 if ([obj objectForKey:@"statusCode"] != nil)
                     rc = [[obj objectForKey:@"statusCode"] integerValue];
                 else
                     rc = [[obj objectForKey:@"rawStringStatus"] integerValue];
                 
                 switch (rc) {
                     case SUCCESS:
                     {
                         NSAlert *alert = [[NSAlert alloc] init];
                         [alert setMessageText:NSLocalizedString(@"Edit group name succeed!", @"")];
                         [alert runModal];
                         NSMutableArray *group = [NSMutableArray arrayWithArray:[self.arrayOfGroups objectAtIndex:self.selectedGroup]];
                         NSMutableArray *tempGroup = [NSMutableArray arrayWithCapacity:0];
                         [tempGroup addObject:self.groupName];
                         
                         for (int i = 1; i < [group count]; i++) {
                             [tempGroup addObject:[group objectAtIndex:i]];
                         }
                         //NSArray *arrGroupName = [NSArray arrayWithObject:self.groupName];
                         //group replaceObjectsAtIndexes:0 withObjects:arrGroupName];
                         [self.arrayOfGroups removeObjectAtIndex:self.selectedGroup];
                         //self.arrayOfGroups replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndex:self.selectedGroup] withObjects:tempGroup];
                         [self.arrayOfGroups addObject:tempGroup];
                         self.arrayOfGroups = [NSMutableArray arrayWithArray:[[NSSet setWithArray: self.arrayOfGroups] allObjects]];
                         [self.tbEditContact reloadData];
                         
                         return;
                     }
                         break;
                     default:
                     {
                         NSAlert *alert = [[NSAlert alloc] init];
                         [alert setMessageText:NSLocalizedString(@"RenameGroupFault", @"")];
                         [alert runModal];
                    }
                         return;
                         break;
                 }
             }
             //if ([obj objectForKey:@"httpErrorCode"] != nil)
                 //nslog(@"AddContactView addGroupResult httpErrorCode: %@", [obj objectForKey:@"httpErrorCode"]);
                NSAlert *alert = [[NSAlert alloc] init];
               [alert setMessageText:NSLocalizedString(@"DeleteTrustContactUnknownErrorKey", @"")];
               [alert runModal];
}



- (void)ListKeyLogById:(NSString *)keyIdString 
{
    
    USAVClient *client = [USAVClient current];
    NSString *subParameters = [NSString stringWithFormat:@"%@%@%@%@%@", keyIdString, @"\n",
                               [[NSString alloc] initWithFormat:@"%d",0], @"\n",
                               [[NSString alloc] initWithFormat:@"%d",self.maxResult]];
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@%@", [client emailAddress], @"\n", [client getDateTimeStr], @"\n", subParameters, @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    NSString *signature = [client generateSignature:stringToSign withKey:client.password];
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:[client emailAddress]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    
    // add 'params' and the child parameters
    GDataXMLElement * paramsElement = [GDataXMLNode elementWithName:@"params"];
    paramElement = [GDataXMLNode elementWithName:@"keyId" stringValue:keyIdString];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"marker" stringValue:[[NSString alloc] initWithFormat:@"%d", 0]];
    [paramsElement addChild:paramElement];
    
    paramElement = [GDataXMLNode elementWithName:@"maxResults" stringValue:[[NSString alloc] initWithFormat:@"%d",self.maxResult]];
    [paramsElement addChild:paramElement];
    
    [requestElement addChild:paramsElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api listKeyLogById:encodedGetParam target:(id)self selector:@selector(listKeyLogByIdCallBack:)];
}

-(void)listKeyLogByIdCallBack:(NSDictionary*)obj {
   
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"TimeStampError", @"")];
        [alert runModal];
        
        return;
    }
    
    if (!obj || [[obj objectForKey:@"statusCode"] integerValue] != 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"PermissionDenied", @"")];
        [alert runModal];
        
        return;
    }
    
    NSMutableArray *keyLogList = [NSMutableArray arrayWithCapacity:0];

    for(id log in [obj objectForKey:@"memberList"]) {
        if ([[log objectForKey:@"Operation"] isEqualToString:@"Decrypt File"]) {
            [keyLogList addObject:log];
        }
    }
    
    [self.scrollViewMain setHidden:YES];
    [self.scrollViewHistory setHidden:NO];
    
    [self.btnContactList setEnabled:NO];
    [self.txtLastOperation setStringValue:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Last Operation", @""), NSLocalizedString(@"File History", @"")]];
    [self.txtTileMain setStringValue:NSLocalizedString(@"        File History", @"")];
    [self.txtTileSub setStringValue:[self.fileNames objectAtIndex:0]];
    NSData *keyId = [[UsavFileHeader defaultHeader] getKeyIDFromFile:[self.paths objectAtIndex:0]];
    NSString *keyIdString = [keyId base64EncodedString];
    self.keyIdString = keyIdString;
    self.actionState = history;
    [self determineBtnStateBy:self.actionState];
    
    [self.logList addObjectsFromArray:keyLogList];
    [self.tbHistory reloadData];
}

-(void) checkUpdates {
    USAVClient *client = [USAVClient current];
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement;
    
    paramElement = [GDataXMLNode elementWithName:@"os" stringValue:@"Mac"];
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    //NSLog(@"getParam encoding: raw:%@", requestElement);
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //NSLog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [client.api checkClientUpdate:encodedGetParam target:(id)self selector:@selector(checkUpdatesResult:)];
}

-(NSString *)filenameConflictSovlerForEncrypt:(NSString *)newFile forPath:(NSString *)path
{
    
    //newly added file's property
    NSString *newFilesExtension = [newFile pathExtension];
    NSString *newFileNameWithOutExtension = [newFile stringByDeletingPathExtension];
    
    if ([newFileNameWithOutExtension length] >= 3) {
        NSRange indexRange2 = {[newFileNameWithOutExtension length] -  3, 3};
        //[existedFilesNameWithOutExtension getCharacters:threeChar range:indexRange];
        
        //check if it is a "()"
        NSString *lastThreeChars = [newFileNameWithOutExtension substringWithRange:indexRange2];
        
        if ([lastThreeChars characterAtIndex:0] == '(') {
            NSRange withoutThree = {0,[newFileNameWithOutExtension length] - 3};
            newFileNameWithOutExtension = [newFileNameWithOutExtension substringWithRange:withoutThree];
        }
    }
    
    //file already in the folder
    
    NSString *existedFilesExtension; //This should be uSav
    NSString *existedFilesOriginExtension;
    NSString *existedFilesNameWithOutExtension;
    
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    int numAllfile = [allFile count];
    
    int postFix = 0;
    BOOL firstTime = true;
    
    for (int i = 0; i < numAllfile; i++) {
        //Get one file's full name
        NSString *singleFile = [allFile objectAtIndex:i];
        
        existedFilesExtension = [singleFile pathExtension];
        existedFilesOriginExtension = [[singleFile stringByDeletingPathExtension] pathExtension];
        existedFilesNameWithOutExtension = [[singleFile stringByDeletingPathExtension] stringByDeletingPathExtension];
        
        NSString *potentialThreeChars;
        if ([existedFilesNameWithOutExtension length] >= 3) {
            NSRange indexRange = {[existedFilesNameWithOutExtension length] - 3, 3};
            potentialThreeChars = [existedFilesNameWithOutExtension substringWithRange:indexRange];
        }
        
        if (![existedFilesOriginExtension isEqualToString:newFilesExtension]) {
            //if no extension conflict then check next item
            continue;
        }
        
        if ([potentialThreeChars characterAtIndex:0] == '(') {
            NSRange withoutThree = {0,[existedFilesNameWithOutExtension length] - 3};
            if (![[existedFilesNameWithOutExtension substringWithRange:withoutThree] isEqualToString: newFileNameWithOutExtension])
                //if no file name conflict then check next item
                continue;
        } else if (![existedFilesNameWithOutExtension isEqualToString:newFileNameWithOutExtension]) {
            continue;
        }
        
        if ([potentialThreeChars characterAtIndex:0] == '(') {
            NSArray *removeClouse = [potentialThreeChars componentsSeparatedByString:@"("];
            int fileIndex = [[[[removeClouse objectAtIndex:1] componentsSeparatedByString:@"("] objectAtIndex:0] intValue];
            if (fileIndex >= postFix) {
                postFix  = fileIndex + 1;
            }
        } else if(firstTime){
            postFix = 1;
        }
        firstTime = false;
        
    }
    
    if (postFix == 0) {
        return [NSString stringWithFormat:@"%@%@", newFile, @".usav"];
    } else {
        return [NSString stringWithFormat:@"%@%@%d%@%@%@", newFileNameWithOutExtension, @"(", postFix, @").", newFilesExtension, @".usav"];
    }
}

-(NSString *)filenameConflictSovler:(NSString *)originalFile forPath:(NSString *)path
{
    NSString *orgExtension = [originalFile pathExtension];
    NSString *orgNoExtension = [originalFile stringByDeletingPathExtension];
    
    NSMutableArray *allFile = [NSMutableArray arrayWithCapacity:0];
    [allFile addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:path error:nil]];
    
    int numAllfile = [allFile count];
    
    int postFix = 0;
    BOOL firstTime = true;
    
    for (int i = 0; i < numAllfile; i++) {
        //if file name already exist
        NSString *singleFile = [allFile objectAtIndex:i];
        
        if ([[singleFile pathExtension] caseInsensitiveCompare:@"usav"] == NSOrderedSame) {
            
            NSArray *file = [[[singleFile  stringByDeletingPathExtension] stringByDeletingPathExtension] componentsSeparatedByString:@"("];
            NSString *fileExtension = [[singleFile  stringByDeletingPathExtension] pathExtension];
            
            if ([[file objectAtIndex:0] isEqualToString:orgNoExtension] && [fileExtension isEqualToString:orgExtension]) {
                if([file count] > 1) {
                    postFix = [[file objectAtIndex:1] intValue] + 1;
                } else if(firstTime){
                    postFix = 1;
                }
                firstTime = false;
            }
            
        }
    }
    if (postFix == 0) {
        return [NSString stringWithFormat:@"%@%@", originalFile, @".usav"];
    } else {
        return [NSString stringWithFormat:@"%@%@%d%@%@%@", orgNoExtension, @"(", postFix, @").", orgExtension, @".usav"];
    }
}

- (void)checkUpdatesResult:(NSDictionary*)obj {
    if ([[obj objectForKey:@"statusCode"] integerValue] == 256) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"UsernameError", @"")];
        [alert runModal];
        //[self listTrustedContactStatus];
        return;
    }
    
    if (obj != nil) {
        //force update
        if ([[obj objectForKey:@"leastVersionCode"] integerValue] > [NSLocalizedString(@"versionNumber", @"") integerValue]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"You must upgrade uSav by download latest version from www.nwstor.com", @"")];
            [alert runModal];
        }
        
        else if ([[obj objectForKey:@"versionCode"] integerValue] > [NSLocalizedString(@"versionNumber", @"") integerValue]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"You can upgrade uSav by download latest version from www.nwstor.com", @"")];
            [alert runModal];
        }
    }
    [self listTrustedContactStatus];

}

@end

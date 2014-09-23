//
//  mainWindowController.h
//  usavMac
//
//  Created by NWHKOSX49 on 16/7/13.
//  Copyright (c) 2013 nwStor. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface mainWindowController : NSWindowController<NSDraggingDestination, NSPasteboardItemDataProvider, NSMatrixDelegate, NSTextFieldDelegate>
@property (weak) IBOutlet NSTextField *txtRegistrationSucceed;

@property (weak) IBOutlet NSTextField *txtRegisterEmail;
@property (weak) IBOutlet NSTextField *txtRegisterReEnterEmail;
@property (weak) IBOutlet NSTextField *txtRegisterPassword;
@property (weak) IBOutlet NSTextField *txtRegisterReEnterPassword;

@property (weak) IBOutlet NSTextField *tFieldRegisterEmail;
@property (weak) IBOutlet NSTextField *tFieldRegisterReEnterEmail;

@property (weak) IBOutlet NSSecureTextField *tFieldRegisterReEnterPassword;
@property (weak) IBOutlet NSSecureTextField *tFieldRegisterPassword;

@property (weak) IBOutlet NSButton *btnWelcomeBack;
@property (weak) IBOutlet NSTextField *txtWelcomeLeft;
@property (weak) IBOutlet NSTextField *txtWelcomeTheme;
@property (weak) IBOutlet NSMatrix *radWelcomeHaveAccountAlready;
@property (weak) IBOutlet NSImageView *imgWelcomeTheme;
@property (weak) IBOutlet NSButton *btnWelcomeContinue;

@property (weak) IBOutlet NSTextField *txtLoginEmail;
@property (weak) IBOutlet NSTextField *txtLoginPassword;
@property (weak) IBOutlet NSTextField *tFieldLoginEmail;
@property (weak) IBOutlet NSSecureTextField *tFieldLoginPassword;

@property (weak) IBOutlet NSTextField *txtUserWarning;
@property (weak) IBOutlet NSButton *btnRegistrationSucceed;

@property (weak) IBOutlet NSButton *ckboxTermOfService;




@end

//
//  mainWindowController.m
//  usavMac
//
//  Created by NWHKOSX49 on 16/7/13.
//  Copyright (c) 2013 nwStor. All rights reserved.
//

#import "mainWindowController.h"
#import "GDataXMLNode.h"
#import "USAVClient.h"
#import "API.h"
#import "USAVLock.h"
#import "workingController.h"
#import "NSAttributedString+Hyperlink.h"
#import "SubNSTextField.h"
@interface mainWindowController ()
@property (nonatomic) int state;
@property (nonatomic, strong) NSString *useremail, *password;
@property (nonatomic, strong) workingController *wc;
@property (nonatomic, strong) NSTextView *viewForgetPassword;
@property (nonatomic, strong) NSTextView *viewTermOfSev;
@end

@implementation mainWindowController
- (IBAction)goToLoginPage:(id)sender {
    self.state = 2;
    [self hideRegistrationPage];
    [self displayLoginPage];
    [self.txtRegistrationSucceed setHidden:YES];
    [self.btnRegistrationSucceed setHidden:YES];
    [self.tFieldLoginEmail setStringValue:[self.tFieldRegisterEmail stringValue]];
}

- (IBAction)welcomBack:(id)sender {
    [self.radWelcomeHaveAccountAlready setHidden:NO];
    [self.txtWelcomeTheme setHidden:NO];
    [self.imgWelcomeTheme setHidden:NO];
    [self.txtWelcomeLeft setStringValue:NSLocalizedString(@"welcomeTheme", @"")];
    [self.btnWelcomeBack setHidden:YES];
    [self.btnWelcomeContinue setEnabled:YES];
    [self.txtUserWarning setHidden:YES];
    [self.txtRegistrationSucceed setHidden:YES];
    
    if (self.state == 1) {
        [self hideRegistrationPage];
        [self.btnRegistrationSucceed setHidden:YES];
        [self.btnRegistrationSucceed highlight:NO];
    }
    
    if (self.state == 2) {
        [self hideLoginPage];
    }
    
    /*if (self.state == 3) {
       [self hideRegistrationPage]; [self hideLoginPage];
    }*/
    
    self.state = 0;
}

- (IBAction)pressedContinue:(id)sender {
    NSInteger *selected =[self.radWelcomeHaveAccountAlready selectedRow];
  
    [self.radWelcomeHaveAccountAlready setHidden:YES];
    [self.txtWelcomeTheme setHidden:YES];
    [self.imgWelcomeTheme setHidden:YES];
    [self.btnWelcomeBack setHidden:NO];
    [self.btnWelcomeContinue setEnabled:NO];
    
    if (self.state == 0) {
        if (selected == 0) {
            [self.txtWelcomeLeft setStringValue:NSLocalizedString(@"createUsavAccount", @"")];

            [self displayRegistrationPage];
            [self.viewTermOfSev setHidden:NO];
            [self.ckboxTermOfService setHidden:NO];
            self.state = 1;
        } else {
            [self.txtWelcomeLeft setStringValue:NSLocalizedString(@"loginLeft", @"")];
            [self.viewForgetPassword setHidden:NO];
            [self displayLoginPage];
            self.state = 2;
        }
    }else if (self.state == 1) {
        [self.tFieldRegisterEmail setEnabled:NO];
        [self.tFieldRegisterPassword setEnabled:NO];
        [self.tFieldRegisterReEnterEmail setEnabled:NO];
        [self.tFieldRegisterReEnterPassword setEnabled:NO];
        
        [self registerAccount];
    }else if (self.state == 2) {
        [self login];
    }
}

- (void)login {
    [self.txtUserWarning setHidden:NO];
    [self.txtUserWarning setStringValue:NSLocalizedString(@"", @"")];
    
    if([self validateLoginInfo]) {
        [self doLogin];
    }
}

- (void)registerAccount {
    [self.txtUserWarning setHidden:NO];
    [self.txtUserWarning setStringValue:NSLocalizedString(@"", @"")];
    
    if([self validateRegisterInfo]) {
        [self doRegister];
    }
}

-(void)doLogin {
    self.useremail = [self.tFieldLoginEmail stringValue];
    self.password = [self.tFieldLoginPassword stringValue];
    [self.txtUserWarning setStringValue:NSLocalizedString(@"StartLogin", @"")];
    [self.btnWelcomeBack setEnabled:NO];
        
    [self getAccountInfo];
}

-(void)registerUsavAccount
{
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"accountId" stringValue:self.useremail];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"password" stringValue:self.password];
    [requestElement addChild:paramElement];

    paramElement = [GDataXMLNode elementWithName:@"lang" stringValue:NSLocalizedString(@"LanguageCode", @"")];
    [requestElement addChild:paramElement];

    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];

    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];

    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    [[USAVClient current].api register:encodedGetParam target:self selector:@selector(registerCallback:)];
}

-(void) registerCallback:(NSDictionary*)obj {
    BOOL result = true;
    NSString *message = @"";
    [self.tFieldRegisterEmail setEnabled:YES];
    [self.tFieldRegisterPassword setEnabled:YES];
    [self.tFieldRegisterReEnterEmail setEnabled:YES];
    [self.tFieldRegisterReEnterPassword setEnabled:YES];
    
    if (([obj objectForKey:@"httpErrorCode"] != nil)) {
        message = NSLocalizedString(@"RegisterUnknownStatusCodeKey", @"");
        [self.txtUserWarning setStringValue:message];
        return;
    }
    
    if (obj == nil) {
        message = NSLocalizedString(@"TimeStampError_Registration", @"");
        [self.txtUserWarning setStringValue:message];
        [self.btnWelcomeContinue setEnabled:YES];
        [self.btnWelcomeBack setEnabled:YES];
        return;
    }
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
        message = NSLocalizedString(@"TimeStampError_Registration", @"");
        return;
    }
    
    if ((obj != nil) &&
        ([obj objectForKey:@"httpErrorCode"] == nil)) {
        // normal/good case
        //nslog(@"%@: registerCallback: resp: %@", [self class], obj);
        
        NSString *rawStringStatus = [obj objectForKey:@"rawStringStatus"];
        int rawStatus = [rawStringStatus integerValue];
        
        switch (rawStatus) {
            case SUCCESS:
            {
                message = NSLocalizedString(@"RegisterSuccessKey", @"");
                [self hideRegistrationPage];
                [self.btnRegistrationSucceed setHidden:NO];
                [self.btnRegistrationSucceed highlight:YES];
                
                [self.txtRegistrationSucceed setStringValue:NSLocalizedString(@"RegisterSuccessItem", @"")];
                [self.txtRegistrationSucceed setHidden:NO];
            }
                break;
            case TIMESTAMP_OLD:
            {
                message = NSLocalizedString(@"RegisterTimestampOldKey", @"");
            }
                break;
            case TIMESTAMP_FUTURE:
            {
                message = NSLocalizedString(@"RegisterTimestampFutureKey", @"");
            }
                break;
            case INVALID_ACC_ID:
            {
                message = NSLocalizedString(@"RegisterInvalidAccIdKey", @"");
            }
                break;
            case ACC_EXIST:
            {
                message = NSLocalizedString(@"UserNameTakenKey", @"");
            }
                break;
            case UNSECURE_PASSWORD:
            {
                message = NSLocalizedString(@"RegisterUnsecurePasswordKey", @"");
            }
                break;
            case INVALID_EMAIL:
            {
                message = NSLocalizedString(@"RegisterInvalidEmailKey", @"");
            }
                break;
            case EMAIL_IN_USE:
            {
                message = (@"RegisterEmailInUseKey", @"");
            }
                break;
            default:
            {
               message = NSLocalizedString(@"RegisterUnknownStatusCodeKey", @"");
            }
                break;
        }
        [self.txtUserWarning setStringValue:message];
        [self.txtUserWarning setHidden:NO];
        [self.btnWelcomeBack setEnabled:YES];
        //[self hideRegistrationPage];
        //[self displayLoginPage];
        return;
    }
    
    if (obj == nil) {
        //nslog(@"%@: resp is nil", [self class]);
    }
    
    if ([obj objectForKey:@"httpErrorCode"] == nil) {
        //nslog(@"%@: http error code: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
    }
    
}

-(void)doRegister {
    self.useremail = [self.tFieldRegisterEmail stringValue];
    self.password = [self.tFieldRegisterPassword stringValue];
    
    [self.txtUserWarning setStringValue:NSLocalizedString(@"StartRegistration", @"")];
    [self.btnWelcomeBack setEnabled:NO];
    [self registerUsavAccount];
}pascal

- (BOOL)validateLoginInfo {
    BOOL result = true;
    NSString *errMessage = @"";
    
    if(![self isValidPassword:[self.tFieldLoginPassword stringValue]]) {
        errMessage = NSLocalizedString(@"InvalidPassword", @"");
        [self.txtLoginPassword setTextColor:[NSColor redColor]];
        result = false;
    } else {
        [self.txtLoginPassword setTextColor:[NSColor blackColor]];
    }
    
    if(![self isValidEmail:[self.tFieldLoginEmail stringValue]]) {
        errMessage = NSLocalizedString(@"InvalidEmailAddress", @"");
        [self.txtLoginEmail setTextColor:[NSColor redColor]];
        result = false;
    } else {
        [self.txtLoginEmail setTextColor:[NSColor blackColor]];
    }
    
    [self.txtUserWarning setStringValue:errMessage];
    [self.txtUserWarning setHidden:NO];
    
    return result;
}

- (BOOL)validateRegisterInfo {
    BOOL result = true;
    NSString *errMessage = @"";
    
    if (![[self.tFieldRegisterPassword stringValue] isEqualToString:[self.tFieldRegisterReEnterPassword stringValue]]) {
        errMessage = NSLocalizedString(@"InvalidConfirmPassword", @"");
        [self.txtRegisterReEnterPassword setTextColor:[NSColor redColor]];
        result = false;
    } else {
        [self.txtRegisterReEnterPassword setTextColor:[NSColor blackColor]];
    }
    
    if(![self isValidPassword:[self.tFieldRegisterPassword stringValue]]) {
        errMessage = NSLocalizedString(@"InvalidPassword", @"");
        [self.txtRegisterPassword setTextColor:[NSColor redColor]];
        result = false;
    } else {
        [self.txtRegisterPassword setTextColor:[NSColor blackColor]];
    }
    
    if (![[self.tFieldRegisterEmail stringValue] isEqualToString:[self.tFieldRegisterReEnterEmail stringValue]]) {
        errMessage = NSLocalizedString(@"InvalidConfirmEmail", @"");
        [self.txtRegisterReEnterEmail setTextColor:[NSColor redColor]];
        result = false;
    } else {
        [self.txtRegisterReEnterEmail setTextColor:[NSColor blackColor]];
    }
    
    if(![self isValidEmail:[self.tFieldRegisterEmail stringValue]]) {
        errMessage = NSLocalizedString(@"InvalidEmailAddress", @"");
        [self.txtRegisterEmail setTextColor:[NSColor redColor]];
        result = false;
    } else {
        [self.txtRegisterEmail setTextColor:[NSColor blackColor]];
    }
    
    [self.txtUserWarning setStringValue:errMessage];
    [self.txtUserWarning setHidden:NO];
    if(!result) {

        [self.tFieldRegisterEmail setEnabled:YES];
        [self.tFieldRegisterPassword setEnabled:YES];
        [self.tFieldRegisterReEnterEmail setEnabled:YES];
        [self.tFieldRegisterReEnterPassword setEnabled:YES];
        
        [self.btnWelcomeContinue setEnabled:YES];
    }
    
    return result;
}

- (BOOL)isValidEmail:(NSString *) email
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

- (BOOL)isValidPassword: (NSString *) email
{
    if ([email length] < 8 || [email length] > 49) {
        return false;
    }
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(.*[a-zA-Z].*\\d.*)|(.*\\d.*[a-zA-Z].*)$" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
    
    if (rangeOfFirstMatch.location == NSNotFound || rangeOfFirstMatch.length != [email length]) {
        return false;
    }
    return true;
}

- (void)displayLoginPage {
    [self setHiddenForLoginPage:NO];
}

- (void)hideLoginPage {
    [self setHiddenForLoginPage:YES];
    [self.viewForgetPassword setHidden:YES];
}

- (void)setHiddenForLoginPage:(BOOL) swi {
    [self.txtLoginEmail setHidden:swi];
    [self.txtLoginPassword setHidden:swi];
    
    [self.tFieldLoginEmail setHidden:swi];
    [self.tFieldLoginPassword setHidden:swi];
}

- (void)displayRegistrationPage {
    [self setHiddenForRegistrationPage:NO];
}

- (void)hideRegistrationPage {
    [self setHiddenForRegistrationPage:YES];
}

- (void) setHiddenForRegistrationPage:(BOOL) swi {
    [self.txtRegisterEmail setHidden:swi];
    [self.txtRegisterReEnterEmail setHidden:swi];
    [self.txtRegisterPassword setHidden:swi];
    [self.txtRegisterReEnterPassword setHidden:swi];
    
    [self.tFieldRegisterEmail setHidden:swi];
    [self.tFieldRegisterReEnterEmail setHidden:swi];
    [self.tFieldRegisterPassword setHidden:swi];
    [self.tFieldRegisterReEnterPassword setHidden:swi];
    
    [self.viewTermOfSev setHidden:swi];
    [self.ckboxTermOfService setHidden:swi];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (IBAction)checkBoxSelected:(id)sender {
    if([self registerInfoAllInputed]) {
        [self.btnWelcomeContinue setEnabled:YES];
        [self.btnWelcomeContinue highlight:YES];
    } else {
        [self.btnWelcomeContinue setEnabled:NO];
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    //register
    if(self.state == 1) {
        if([self registerInfoAllInputed]) {
            [self.btnWelcomeContinue setEnabled:YES];
            [self.btnWelcomeContinue highlight:YES];
        } else {
            [self.btnWelcomeContinue setEnabled:NO];
        }
    } else if(self.state == 2) {
        if([self loginInfoAllInputed]) {
            [self.btnWelcomeContinue setEnabled:YES];
            [self.btnWelcomeContinue highlight:YES];
        } else {
            [self.btnWelcomeContinue setEnabled:NO];
        }
    }
}

- (BOOL)loginInfoAllInputed
{
    return ([[self.tFieldLoginEmail stringValue] length] && [[self.tFieldLoginPassword stringValue] length]);
}

- (BOOL)registerInfoAllInputed
{
    return ([[self.tFieldRegisterEmail stringValue] length] && [[self.tFieldRegisterReEnterEmail stringValue] length] && [[self.tFieldRegisterPassword stringValue] length] && [[self.tFieldRegisterReEnterPassword stringValue] length] && [self.ckboxTermOfService state]);
}

- (void)windowDidLoad
{
    //set the hyper link for forgot password
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://webapi.usav-nwstor.com/%@/password",NSLocalizedString(@"LanguageCode", @"")]];
                  
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString: [NSAttributedString hyperlinkFromString:NSLocalizedString(@"ForgetPasswrod", @"") withURL:url]];
    
    self.viewForgetPassword = [[NSTextView alloc] initWithFrame:NSMakeRect(350, 235, 280, 40)];
    [self.viewForgetPassword setDrawsBackground:NO];
    [self.viewForgetPassword setHidden:YES];
    [[self.viewForgetPassword  textStorage] setAttributedString: string];
    [self.window.contentView addSubview:self.viewForgetPassword];
    
    //set the hyper link for term of service
    
    NSURL* url2 = [NSURL URLWithString:NSLocalizedString(@"UsavPasswordRecoverLink", @"")];
    
    
    NSFont *labelFont = [NSFont fontWithName:@"Times-Roman" size:15];
    //UIColor * labelColor = [UIColor colorWithWhite:1 alpha:1];
    

    
    NSMutableAttributedString* string2 = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@ {
        NSFontAttributeName : labelFont,
        NSKernAttributeName : [NSNumber numberWithFloat:1]}];

    
    [string2 appendAttributedString:  [[NSAttributedString alloc] initWithString:NSLocalizedString(@"IHavRead", @"") attributes:@ {
        NSFontAttributeName : labelFont,
        NSKernAttributeName : [NSNumber numberWithFloat:0.2]}]];

    [string2 appendAttributedString: [NSAttributedString hyperlinkFromString:NSLocalizedString(@"TermOfService", @"") withURL:url2]];
   
    self.viewTermOfSev = [[NSTextView alloc] initWithFrame:NSMakeRect(165, 143, 350, 40)];
    [self.viewTermOfSev setDrawsBackground:NO];
    [self.viewTermOfSev setHidden:YES];
    [[self.viewTermOfSev textStorage] setAttributedString: string2];
    [self.window.contentView addSubview:self.viewTermOfSev];
  
    //check box
    [self.ckboxTermOfService setHidden:YES];
    //[self.ckboxTermOfService setState:0];
    
    [self.window setTitle:NSLocalizedString(@"UsavSetup", @"")];
    
    [self.btnRegistrationSucceed setTitle:NSLocalizedString(@"Login", @"")];
  
    [self.txtWelcomeLeft setStringValue:NSLocalizedString(@"welcomeLeft", @"")];
    [self.txtWelcomeTheme setStringValue:NSLocalizedString(@"welcomeTheme", @"")];
    [self.btnWelcomeContinue setTitle:NSLocalizedString(@"welcomeContinue", @"")];
    [self.btnWelcomeBack setTitle:NSLocalizedString(@"welcomeBack", @"")];
    
    [self.txtRegisterEmail setStringValue:NSLocalizedString(@"registerEmail", @"")];
    [self.txtRegisterReEnterEmail setStringValue:NSLocalizedString(@"registerEmailReEnter", @"")];
    [self.txtRegisterPassword setStringValue:NSLocalizedString(@"registerPassword", @"")];
    [self.txtRegisterReEnterPassword setStringValue:NSLocalizedString(@"registerPasswordReEnter", @"")];
  
    [self.txtLoginEmail setStringValue:NSLocalizedString(@"loginEmail", @"")];
    [self.txtLoginPassword setStringValue:NSLocalizedString(@"loginPassword", @"")];

    NSArray *cellArray = [self.radWelcomeHaveAccountAlready cells];
    [[cellArray objectAtIndex:0] setTitle:NSLocalizedString(@"iDontHaveUsav", @"")];
    [[cellArray objectAtIndex:1] setTitle:NSLocalizedString(@"iHaveUsav", @"")];
    
    [self.btnWelcomeContinue highlight:YES];
    [self.tFieldRegisterEmail setDelegate:self];
    [self.tFieldRegisterPassword setDelegate:self];
    [self.tFieldRegisterReEnterEmail setDelegate:self];
    [self.tFieldRegisterReEnterPassword setDelegate:self];
    
    [self.tFieldLoginEmail setDelegate:self];
    [self.tFieldLoginPassword setDelegate:self];
    
    if ([USAVClient current] == nil)
		[[USAVClient alloc] init];
    
    [super windowDidLoad];
}

-(void)getAccountInfo
{
    NSString *stringToSign = [NSString stringWithFormat:@"%@%@%@%@%@", self.useremail, @"\n", [[USAVClient current] getDateTimeStr], @"\n", @"\n"];
    
    //nslog(@"stringToSign: %@", stringToSign);
    NSString *signature = [[USAVClient current] generateSignature:stringToSign withKey:self.password];
    //nslog(@"signature: %@", signature);
    
    GDataXMLElement * requestElement = [GDataXMLNode elementWithName:@"request"];
    GDataXMLElement * paramElement = [GDataXMLNode elementWithName:@"account" stringValue:self.useremail];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"timestamp" stringValue:[[USAVClient current] getDateTimeStr]];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"signature" stringValue:signature];
    [requestElement addChild:paramElement];
    paramElement = [GDataXMLNode elementWithName:@"params" stringValue:@""];
    [requestElement addChild:paramElement];
    
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithRootElement:requestElement];
    NSData *xmlData = document.XMLData;
    
    NSString *getParam = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *encodedGetParam = [[USAVClient current] encodeToPercentEscapeString:getParam];
    
    //nslog(@"getParam encoding: raw:%@ encoded:%@", getParam, encodedGetParam);
    
    [[USAVClient current].api getAccountInfo:encodedGetParam target:self selector:@selector(getAccountInfoResultCallback:)];
}

-(void)getAccountInfoResultCallback:(NSDictionary*)obj {
    NSString *rmes;
    //nslog(@"%@", obj);
    
    if ([[obj objectForKey:@"statusCode"] integerValue] == 261 || [[obj objectForKey:@"statusCode"] integerValue] == 260) {
       rmes = NSLocalizedString(@"TimeStampError_Registration", @"");
        return;
    }
    
    // get GetAccountInfo as if Login has occured
    if (obj == nil) {
            rmes = NSLocalizedString(@"TimeStampError_Registration", @"");
            [self.txtUserWarning setStringValue:rmes];
            [self.btnWelcomeContinue setEnabled:YES];
            [self.btnWelcomeBack setEnabled:YES];
            return;
    }
    
    if ((obj != nil) &&
        ([obj objectForKey:@"httpErrorCode"] == nil)) {
               
        NSString *statusCodeStr = [obj objectForKey:@"statusCode"];
        int statusCode = [statusCodeStr integerValue];
        
        switch (statusCode) {
            case SUCCESS:
            { rmes =  NSLocalizedString(@"GetAccountInfoSuccessKey", @"");
                
                [[USAVClient current] setPassword: self.password];
                [[USAVClient current] setUsername:[obj objectForKey:@"name"]];
                [[USAVClient current] setEmailAddress:[obj objectForKey:@"accountId"]];
                [[USAVClient current] setUserHasLogin:YES];
                [[USAVLock defaultLock] setUserLoginOn];
      
                [self.window orderOut:self];
                self.wc = [[workingController alloc] initWithWindowNibName:@"workingController"];
                [self.wc showWindow:self];

                [[USAVLock defaultLock] setMainWindowOpenOn];
            }
                break;
            case DISABLE_USER:
            {
                rmes = NSLocalizedString(@"DisabledUser", @"");
            }
                break;
            default:
            {
                rmes = NSLocalizedString(@"GetAccountInfoFailKey", @"");
                [[USAVClient current] setUserHasLogin:NO];
            }
                break;
        }
    }
    
    [self.txtUserWarning setStringValue: rmes];
    [self.btnWelcomeBack setEnabled:YES];
    if (obj == nil) {
        //nslog(@"%@: resp is nil", [self class]);
    }
    
    if ([obj objectForKey:@"httpErrorCode"] == nil) {
        //nslog(@"%@: http error code: %@", [self class], [obj objectForKey:@"httpErrorCode"]);
    }
}

@end

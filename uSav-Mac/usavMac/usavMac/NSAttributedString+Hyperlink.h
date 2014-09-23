//
//  NSAttributedString+Hyperlink.h
//  usavMac
//
//  Created by NWHKOSX49 on 25/7/13.
//  Copyright (c) 2013 nwStor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Hyperlink)
 +(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
@end

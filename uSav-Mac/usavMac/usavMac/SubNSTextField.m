//
//  SubNSTextField.m
//  usavMac
//
//  Created by NWHKOSX49 on 26/7/13.
//  Copyright (c) 2013 nwStor. All rights reserved.
//

#import "SubNSTextField.h"

@implementation SubNSTextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)resetCursorRects
{
    [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

@end

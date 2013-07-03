//
//  MyTextField.m
//  ContactBubbles
//
//  Created by Cannon, Dustin on 6/25/13.
//  Copyright (c) 2013 Cannon, Dustin. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField

- (id)init
{
    return [super init];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)deleteBackward
{
    if (self.text.length == 0) {
        if ([self.delegate respondsToSelector:@selector(textFieldDeleteWasPressedWhileEmpty)]) {
            [self.delegate textFieldDeleteWasPressedWhileEmpty];
        }
    }
    [super deleteBackward];
}

@end

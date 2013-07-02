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
    NSLog(@"delete was tapped");
    if ([self.text isEqualToString:@""]) {
        NSLog(@"text field is empty");
        
    }
    [super deleteBackward];
}

@end

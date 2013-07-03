//
//  MyTextField.h
//  ContactBubbles
//
//  Created by Cannon, Dustin on 6/25/13.
//  Copyright (c) 2013 Cannon, Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyTextFieldDelegate <UITextFieldDelegate>

@optional

- (void)textFieldDeleteWasPressedWhileEmpty;

@end

@interface MyTextField : UITextField

@property (nonatomic, weak) id <MyTextFieldDelegate> delegate;

@end

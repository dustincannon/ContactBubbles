//
//  ContactPicker.h
//  ContactBubbles
//
//  Created by Cannon, Dustin on 6/25/13.
//  Copyright (c) 2013 Cannon, Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactBubble.h"
#import "MyTextField.h"

@class ContactPicker;

@protocol ContactPickerDelegate <NSObject>

@optional

- (void)contactPickerAddContactButtonTapped:(id)sender;
- (void)contactPickerTextFieldDidChange:(NSString *)textFieldText;
- (void)contactPickerDidRemoveContact:(id)contact;
- (void)contactPickerDidResize:(ContactPicker *)contactPickerView;

@end

@interface ContactPicker : UIView <MyTextFieldDelegate, THContactBubbleDelegate>
{
    MyTextField *_textField;
    UIButton *_addContactsButton;
    NSMutableDictionary *_contacts;
    NSMutableArray *_contactKeys;
    THContactBubble *_selectedBubble;

    BOOL _textFieldShouldRespondToDelete;

    CGFloat _lineHeight;
}

@property (nonatomic, weak) id <ContactPickerDelegate> delegate;

- (void)layoutViews;
- (void)addContact:(NSString *)email;

@end

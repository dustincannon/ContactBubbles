//
//  ContactPicker.m
//  ContactBubbles
//
//  Created by Cannon, Dustin on 6/25/13.
//  Copyright (c) 2013 Cannon, Dustin. All rights reserved.
//

#import "ContactPicker.h"
#import "MyTextField.h"
#import "AddressBookManager.h"

#define kViewPadding 5       // the amount of padding on top and bottom of the view
#define kHorizontalPadding 2 // the amount of padding to the left and right of each contact bubble
#define kVerticalPadding 4   // amount of padding above and below each contact bubble
#define kTextFieldMinWidth 130

@implementation ContactPicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        _contacts = [NSMutableDictionary dictionary];
        _contactKeys = [NSMutableArray array];

        // Create a contact bubble to determine the height of a line
        THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:@"Sample"];
        _lineHeight = contactBubble.frame.size.height + 2 * kVerticalPadding;
        
        self.backgroundColor = [UIColor whiteColor];
        
        // Set up text field
        _textField = [[MyTextField alloc] init];
        _textField.placeholder = @"Placeholder";
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.delegate = self;
        
        // Set up add contacts button
        _addContactsButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [_addContactsButton addTarget:self action:@selector(addContactButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)layoutViews
{
    CGRect frameOfLastBubble = {{0, 0}, {0, 0}};
    CGPoint centerOfLastBubble = {0, 0};

    CGFloat x, y, width, height;
    x = y = width = height = 0;

    // Loop through the contacts adding contact bubbles if necessary
    for (NSString *contact in _contactKeys) {
        THContactBubble *contactBubble = (THContactBubble *)[_contacts objectForKey:contact];
        CGRect bubbleFrame = contactBubble.frame;

        // Size and position the contact bubble
        if (frameOfLastBubble.size.width == 0) {
            // First bubble
            bubbleFrame.origin.x = kHorizontalPadding;
            bubbleFrame.origin.y = kVerticalPadding + kViewPadding;
        } else {
            
        }

        frameOfLastBubble = bubbleFrame;
        contactBubble.frame = bubbleFrame;

        // Add the contact bubble to the view hierarchy if it wasn't already added
        if (contactBubble.superview == nil) {
            [self addSubview:contactBubble];
        }
        centerOfLastBubble = contactBubble.center;
    }

    // Put a text field after the last contact bubble, if it exists
    if (_textField.frame.size.width == 0 || _textField.frame.size.height == 0) {
        [_textField sizeToFit];
        NSLog(@"sizing text field");
    }

    CGFloat minWidth = kTextFieldMinWidth + 2 * kHorizontalPadding;
    CGRect textFieldFrame = CGRectMake(0, 0, _textField.frame.size.width, _textField.frame.size.height);

    CGFloat usableWidth = self.frame.size.width -
                          frameOfLastBubble.origin.x -
                          frameOfLastBubble.size.width -
                          _addContactsButton.frame.size.width;
    //if (usableWidth - minWidth >= 0) {
        // add to the same line
        textFieldFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
        textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x - _addContactsButton.frame.size.width;
    //} else {
        // put text field on next line
    //}

    _textField.frame = textFieldFrame;
    centerOfLastBubble = centerOfLastBubble.y ? centerOfLastBubble : CGPointMake(centerOfLastBubble.x,
                                                                                 _lineHeight / 2 + kVerticalPadding + kViewPadding);
    _textField.center = CGPointMake(_textField.center.x, centerOfLastBubble.y);

    if (_textField.superview == nil) {
        [self addSubview:_textField];
        NSLog(@"adding text field to view");
    }
    
    // Place the add contacts button. It is always on the last line at the right edge of the view and
    // vertically centered on the text field.
    x = self.frame.size.width - (_addContactsButton.frame.size.width / 2);
    y = _textField.center.y;
    _addContactsButton.center = CGPointMake(x, y);
    if (_addContactsButton.superview == nil) {
        [self addSubview:_addContactsButton];
    }

    // Adjust this view's frame
    height = frameOfLastBubble.size.height ? frameOfLastBubble.size.height : _textField.frame.size.height;
    height += 2 * kVerticalPadding + 2 * kViewPadding;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

#pragma mark - UITextField delegate methods

- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Capture delete when textfield is empty
    if ([field.text isEqualToString:@""] && [string isEqualToString:@""]) {
        // Select last bubble
        NSLog(@"delete pressed while field is empty");
    } else {
    
        if ([self.delegate respondsToSelector:@selector(contactPickerTextFieldDidChange:)]) {
            NSString *newText = field.text;

            if ([string isEqualToString:@""]) {
                // Delete key was pressed. Remove character from new text.
                newText = [newText substringWithRange:NSMakeRange(0, newText.length - 1)];
            } else {
                newText = [newText stringByAppendingString:string];
            }

            [self.delegate contactPickerTextFieldDidChange:newText];
        }
    }
    return YES;
}

- (void)addContactButtonTapped:(id)sender
{
    // Send message to delegate
    [self.delegate contactPickerAddContactButtonTapped:sender];
}

- (void)addContact:(NSString *)email
{
    if ([_contactKeys containsObject:email]) {
        // Can only add contact once.
        return;
    }
    [_contactKeys addObject:email];

    THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:email];
    contactBubble.delegate = self;
    [_contacts setObject:contactBubble forKey:email];

    [self layoutViews];
}

#pragma mark - THContactBubble Delegate Methods

- (void)contactBubbleWasSelected:(THContactBubble *)contactBubble
{
    
}

- (void)contactBubbleWasUnSelected:(THContactBubble *)contactBubble
{
    
}

- (void)contactBubbleShouldBeRemoved:(THContactBubble *)contactBubble
{
    
}

@end

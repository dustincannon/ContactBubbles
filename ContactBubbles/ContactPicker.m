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
        _selectedBubble = nil;

        _textFieldShouldRespondToDelete = YES;

        // Create a contact bubble to determine the height of a line
        THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:@"Sample"];
        _lineHeight = contactBubble.frame.size.height + 2 * kVerticalPadding;
        
        self.backgroundColor = [UIColor whiteColor];
        
        // Set up text field
        _textField = [[MyTextField alloc] init];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.delegate = self;
        
        // Set up add contacts button
        _addContactsButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [_addContactsButton addTarget:self action:@selector(addContactButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }

    return self;
}

- (void)layoutViews
{
    CGRect frameOfLastBubble = {{0, 0}, {0, 0}};

    CGFloat x, y, width, height;
    x = y = width = height = 0;

    int lineCount = 0;

    // Loop through the contacts adding contact bubbles if necessary
    for (NSString *contact in _contactKeys) {
        THContactBubble *contactBubble = (THContactBubble *)[_contacts objectForKey:contact];
        [contactBubble adjustSize];
        CGRect bubbleFrame = contactBubble.frame;

        // Size and position the contact bubble
        if (frameOfLastBubble.size.width == 0) {
            // First bubble
            bubbleFrame.origin.x = kHorizontalPadding;
            bubbleFrame.origin.y = (_lineHeight - bubbleFrame.size.height) / 2;

            // If the bubble still won't fit on the line then we have to truncate it
            CGFloat usableWidth = self.frame.size.width - bubbleFrame.origin.x - bubbleFrame.size.width - kHorizontalPadding;
            if (usableWidth < 0) {
                bubbleFrame.size.width = self.frame.size.width - (2 * kHorizontalPadding);
            }
        } else {
            // Check if bubble will fit on the current line
            CGFloat usableWidth = self.frame.size.width -
                                  frameOfLastBubble.origin.x -
                                  frameOfLastBubble.size.width -
                                  _addContactsButton.frame.size.width;
            
            if (usableWidth - bubbleFrame.size.width >= 0) {
                bubbleFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
                bubbleFrame.origin.y = frameOfLastBubble.origin.y;
            } else {
                // Next line
                NSLog(@"bubble won't fit on current line");
                lineCount++;
                bubbleFrame.origin.x = kHorizontalPadding;
                bubbleFrame.origin.y = (lineCount * _lineHeight) + ((_lineHeight - bubbleFrame.size.height) / 2);

                // If the bubble still won't fit on the line then we have to truncate it
                CGFloat usableWidth = self.frame.size.width - bubbleFrame.origin.x - bubbleFrame.size.width - kHorizontalPadding;
                if (usableWidth < 0) {
                    bubbleFrame.size.width = self.frame.size.width - (2 * kHorizontalPadding);
                }
            }
        }

        frameOfLastBubble = bubbleFrame;
        contactBubble.frame = bubbleFrame;

        // Add the contact bubble to the view hierarchy if it wasn't already added
        if (contactBubble.superview == nil) {
            [self addSubview:contactBubble];
        }
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
    if (usableWidth - minWidth >= 0) {
        // add to the same line
        textFieldFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
        textFieldFrame.origin.y = lineCount * _lineHeight + ((_lineHeight - textFieldFrame.size.height) / 2);
        textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x - _addContactsButton.frame.size.width;
    } else {
        // put text field on next line
        lineCount++;
        textFieldFrame.origin.x = kHorizontalPadding;
        textFieldFrame.origin.y = lineCount * _lineHeight + ((_lineHeight - textFieldFrame.size.height) / 2);
        textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x - _addContactsButton.frame.size.width;
    }

    _textField.frame = textFieldFrame;

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
    height = lineCount * _lineHeight + _lineHeight;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

#pragma mark - MyTextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing");
    [_selectedBubble unSelect];
    return YES;
}

- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"] && _textField.text.length) {
        // Return was pressed while the text field contains text.
        // Add a contact and clear the text field.
        [self addContact:_textField.text];
        _textField.text = @"";
    }

    if ([self.delegate respondsToSelector:@selector(contactPickerTextFieldDidChange:)]) {
        NSString *newText = field.text;

        if ([string isEqualToString:@""]) {
            // Delete key was tapped. Remove character from new text.
            newText = [newText substringWithRange:NSMakeRange(0, newText.length - 1)];
        } else {
            newText = [newText stringByAppendingString:string];
        }

        [self.delegate contactPickerTextFieldDidChange:newText];
    }

    return YES;
}

- (void)textFieldDeleteWasPressedWhileEmpty
{
    if (_textFieldShouldRespondToDelete) {
        _selectedBubble = [_contacts objectForKey:[_contactKeys lastObject]];
        [_selectedBubble select];
    }
    _textFieldShouldRespondToDelete = YES;
}

#pragma mark - Add Contact Methods

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
    if (_selectedBubble) {
        [_selectedBubble unSelect];
    }

    _selectedBubble = contactBubble;

    [_textField resignFirstResponder];
}

- (void)contactBubbleWasUnSelected:(THContactBubble *)contactBubble
{
    if (_selectedBubble == contactBubble) {
        _selectedBubble = nil;
    }
    [_textField becomeFirstResponder];
}

- (void)contactBubbleShouldBeRemoved:(THContactBubble *)contactBubble
{
    NSString *contact = [contactBubble name];

    [_contacts removeObjectForKey:contact];
    [_contactKeys removeObject:contact];
    
    [contactBubble removeFromSuperview];
    [self layoutViews];

    _textFieldShouldRespondToDelete = NO;
}

@end

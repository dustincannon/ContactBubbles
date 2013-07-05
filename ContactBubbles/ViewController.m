//
//  ViewController.m
//  ContactBubbles
//
//  Created by Cannon, Dustin on 6/25/13.
//  Copyright (c) 2013 Cannon, Dustin. All rights reserved.
//

#import "ViewController.h"
#import "ContactPicker.h"
#import "AddressBookManager.h"

@interface ViewController ()
{
    UITextField *textField;
    ContactPicker *contactPicker;
}

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        textField = [[UITextField alloc] init];
        textField.placeholder = @"Placeholder";
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [textField sizeToFit];
    [self.view addSubview:textField];

    contactPicker = [[ContactPicker alloc] initWithFrame:CGRectMake(0,
                                                                    textField.frame.origin.y + textField.frame.size.height + 10,
                                                                    self.view.bounds.size.width,
                                                                    50)];
    contactPicker.delegate = self;
    [contactPicker layoutViews];
    [self.view addSubview:contactPicker];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [contactPicker layoutViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ContactPicker delegate methods

- (void)contactPickerTextFieldDidChange:(NSString *)textFieldText
{
    NSLog(@"text changed to: %@", textFieldText);
}

- (void)contactPickerAddContactButtonTapped:(id)sender
{
    // Present the contact selection view
    NSLog(@"add contact button tapped");
    
    AddressBookManager *abm = [AddressBookManager instance];
    [abm pickPeopleInController:self withCallback:^(NSString *firstName, NSString *lastName, NSString *emailAddress) {
        NSLog(@"firstName: %@", firstName);
        NSLog(@"lastName: %@", lastName);
        NSLog(@"emailAddress: %@", emailAddress);

        if (emailAddress) {
            [contactPicker addContact:emailAddress];
        }
    }];
}

@end

//
//  AddressBookManager.m
//  CloudDrivePhotosiOS
//
//  Created by Sean Lu on 6/20/13.
//  Copyright (c) 2013 Cloud Drive. All rights reserved.
//

#import "AddressBookManager.h"

static AddressBookManager* instance;

@interface AddressBookManager()
@property (nonatomic, copy) void (^callback)(NSString* firstName, NSString* lastName, NSString* emailAddress);
@end

@implementation AddressBookManager {
    ABPeoplePickerNavigationController* _picker;
}

+ (id) instance {
    if(instance == nil) {
        instance = [AddressBookManager new];
    }
    return instance;
}

- (void) pickPeopleInController:(UIViewController*)controller withCallback:(void (^)(NSString* firstName, NSString* lastName, NSString* emailAddress))callback
{
    _callback = callback;
    
    if(_picker == nil) {
        _picker = [[ABPeoplePickerNavigationController alloc] init];
        _picker.peoplePickerDelegate = self;
        // Display only a person's phone, email, and birthdate
        //NSArray *displayedItems = @[@(kABPersonPhoneProperty), @(kABPersonEmailProperty),@(kABPersonBirthdayProperty)];
        NSArray *displayedItems = @[@(kABPersonEmailProperty)];
        
        _picker.displayedProperties = displayedItems;
    }
	
	// Show the picker
	[controller presentViewController:_picker animated:YES completion:^{
    }];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self callbackAndCleanWithEmail:nil firstName:nil lastName:nil];
}

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return true;
}

- (void)callbackAndCleanWithEmail:(NSString *)emailAddress firstName:(NSString *)firstName lastName:(NSString *)lastName
{
    [_picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if(_callback) {
            _callback(firstName, lastName, emailAddress);
            _callback = nil;
        }
    }];
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    CFStringRef firstNameRef = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFStringRef lastNameRef = ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
    
    if(ABMultiValueGetCount(multiValue) > 0) {
        NSString* firstName = (__bridge NSString*) firstNameRef;
        if(firstNameRef) CFRelease(firstNameRef);

        NSString* lastName = (__bridge NSString*) lastNameRef;
        if(lastNameRef) CFRelease(lastNameRef);

        CFStringRef emailAddressRef = NULL;
        if(multiValue) {
            CFIndex index = ABMultiValueGetIndexForIdentifier(multiValue, identifier);
            emailAddressRef = (CFStringRef)ABMultiValueCopyValueAtIndex(multiValue, index);
            CFRelease(multiValue);
        }
        NSString* emailAddress = (__bridge NSString*) emailAddressRef;
        if(emailAddressRef) CFRelease(emailAddressRef);
        
        //SMDebug(@"%@, %@, %@", firstName, lastName, emailAddress);
        
        [self callbackAndCleanWithEmail:emailAddress firstName:firstName lastName:lastName];
    } else {
        //SMError(@"expecting 1 or more email address, but got 0 instead");
        [self callbackAndCleanWithEmail:nil firstName:nil lastName:nil];
    }
    return false;
}

@end

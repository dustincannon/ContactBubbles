//
//  AddressBookManager.h
//  CloudDrivePhotosiOS
//
//  Created by Sean Lu on 6/20/13.
//  Copyright (c) 2013 Cloud Drive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddressBookManager : NSObject<ABPeoplePickerNavigationControllerDelegate>

+ (id) instance;

- (void) pickPeopleInController:(UIViewController*)controller withCallback:(void (^)(NSString* firstName, NSString* lastName, NSString* emailAddress))callback;

@end

//
//  contact_API.m
//  Forge
//
//  Created by Connor Dunn on 14/03/2012.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import "JLContactsPermission.h"

#import "contact_API.h"
#import "contact_Delegate.h"
#import "contact_Util.h"


@implementation contact_API

+ (void)select:(ForgeTask*)task {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if (![self addressBookAccessGranted:addressBook]) {
        NSLog(@"error! no access");
        [task error:@"User didn't grant access to address book" type:@"EXPECTED_FAILURE" subtype:nil];

    } else {
        ABPeoplePickerNavigationController *pickerController = [[ABPeoplePickerNavigationController alloc] init];
        
        contact_Delegate *delegate = [[contact_Delegate alloc] initWithTask:task];
        pickerController.peoplePickerDelegate = delegate;
        if (@available(iOS 13.0, *)) {
            pickerController.modalPresentationStyle = UIModalPresentationPopover;
        } else {
            pickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        [[[ForgeApp sharedApp] viewController] presentViewController:pickerController animated:YES completion:nil];
    }
}

+ (void)selectById:(ForgeTask *)task id:(NSString *) contactId {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if (![self addressBookAccessGranted:addressBook]) {
        [task error:@"User didn't grant access to address book" type:@"EXPECTED_FAILURE" subtype:nil];
        return;
    } else {
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, (ABRecordID)[contactId intValue]);
        [task success:[contact_Util dictFrom:person withFields:@[@"name", @"nickname", @"phoneNumbers", @"emails", @"addresses", @"ims", @"organizations", @"birthday", @"note", @"photos", @"categories", @"urls"]]];
        return;
    }
}

+ (void)selectAll:(ForgeTask*)task fields:(NSArray*) fields {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    if (![self addressBookAccessGranted:addressBook]) {
        [task error:@"User didn't grant access to address book" type:@"EXPECTED_FAILURE" subtype:nil];
        return;
    } else {
        NSArray *thePeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
        NSMutableArray *serialisedPeople = [NSMutableArray arrayWithCapacity:[thePeople count]];
        for (int i=0; i < [thePeople count]; i++) {
            ABRecordRef person = CFBridgingRetain([thePeople objectAtIndex:i]);
            [serialisedPeople addObject:[contact_Util dictFrom:person withFields:fields]];
        }
        [task success:serialisedPeople];
        return;
    }
}

+ (void)insert:(ForgeTask*)task contact:(NSDictionary *)contactDict {
    NSLog(@"Called insert: %@", contactDict);
    
    CFErrorRef error;
    ABRecordRef newPerson =
        [contact_Util contactCreateFrom:contactDict error_out:&error];

    if (newPerson == NULL) {
        NSLog(@"insert error! %@", error);
        [task error:@"Couldn't create new contact" type:@"UNEXPECTED_FAILURE" subtype:nil];
        return;
    }
    
    ABAddressBookRef addressBook = ABAddressBookCreate();

    if (![self addressBookAccessGranted:addressBook]) {
        NSLog(@"error! no access");
        [task error:@"User didn't grant access to address book" type:@"EXPECTED_FAILURE" subtype:nil];
    }
    else if (!ABAddressBookAddRecord(addressBook, newPerson, &error)) {
        NSLog(@"error! %@", error);
        [task error:@"couldn't add new record" type:@"UNEXPECTED_FAILURE" subtype:nil];
    }
    else if (!ABAddressBookSave(addressBook, &error)) {
        NSLog(@"error! %@", error);
        [task error:@"couldn't save address book" type:@"UNEXPECTED_FAILURE" subtype:nil];
    }
    else {
        // FINALLY.
        NSString *idStr =
            [NSString stringWithFormat:@"%d", ABRecordGetRecordID(newPerson)];

        [task success:idStr];
    }

    CFRelease(newPerson);
}

+ (BOOL)addressBookAccessGranted:(ABAddressBookRef)addressBook {
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6 or newer
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    return accessGranted;
}

+ (void)add:(ForgeTask*)task contact:(NSDictionary*)contactDict {
    CFErrorRef error;
    ABRecordRef newPerson =
        [contact_Util contactCreateFrom:contactDict error_out:&error];
    
    if (newPerson == NULL) {
        NSLog(@"add error! %@", error);
        [task error:@"Couldn't create new contact" type:@"UNEXPECTED_FAILURE" subtype:nil];
        return;
    }
    
    ABNewPersonViewController *controller = [[ABNewPersonViewController alloc] init];
    controller.displayedPerson = newPerson;
    contact_Delegate *delegate = [[contact_Delegate alloc] initWithTask:task];
    controller.newPersonViewDelegate = delegate;
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                       initWithRootViewController:controller];
    if (@available(iOS 13.0, *)) {
        navigationController.modalPresentationStyle = UIModalPresentationPopover;
    } else {
        navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    [[[ForgeApp sharedApp] viewController] presentViewController:navigationController animated:YES completion:nil];

    CFRelease(newPerson);
}


+ (void)permissions_check:(ForgeTask*)task permission:(NSString *)permission {
    JLPermissionsCore* jlpermission = [self resolvePermission:permission];
    if (jlpermission == NULL) {
        [task success:[NSNumber numberWithBool:NO]];
        return;
    }

    JLAuthorizationStatus status = [jlpermission authorizationStatus];
    [task success:[NSNumber numberWithBool:status == JLPermissionAuthorized]];
}


+ (void)permissions_request:(ForgeTask*)task permission:(NSString *)permission {
    JLPermissionsCore* jlpermission = [self resolvePermission:permission];
    if (jlpermission == NULL) {
        [task success:[NSNumber numberWithBool:NO]];
        return;
    }

    if ([jlpermission authorizationStatus] == JLPermissionAuthorized) {
        [task success:[NSNumber numberWithBool:YES]];
        return;
    }

    NSDictionary* params = task.params;
    NSString* rationale = [params objectForKey:@"rationale"];
    if (rationale != nil) {
        [jlpermission setRationale:rationale];
    }

    [jlpermission authorize:^(BOOL granted, NSError * _Nullable error) {
        [jlpermission setRationale:nil]; // reset rationale
        if (error) {
            [ForgeLog d:[NSString stringWithFormat:@"permissions.check '%@' failed with error: %@", permission, error]];
        }
        [task success:[NSNumber numberWithBool:granted]];
    }];
}


+ (JLPermissionsCore*)resolvePermission:(NSString*)permission {
    JLPermissionsCore* ret = NULL;
    if ([permission isEqualToString:@""]) {
        [ForgeLog d:[NSString stringWithFormat:@"Permission not supported on iOS:%@", permission]];

    } else if ([permission isEqualToString:@"ios.permission.contacts"]) {
        ret = [JLContactsPermission sharedInstance];

    } else {
        [ForgeLog w:[NSString stringWithFormat:@"Requested unknown permission:%@", permission]];
    }

    return ret;
}

@end

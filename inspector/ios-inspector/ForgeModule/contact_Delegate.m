//
//  contact_Delegate.m
//  Forge
//
//  Created by Connor Dunn on 14/03/2012.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import "contact_Delegate.h"
#import "contact_Util.h"

@implementation contact_Delegate

- (contact_Delegate*) initWithTask:(ForgeTask *)initTask {
	if (self = [super init]) {
		task = initTask;
		// "retain"
		me = self;
	}	
	return self;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	NSDictionary *data = [contact_Util dictFrom:person withFields:@[@"name", @"nickname", @"phoneNumbers", @"emails", @"addresses", @"ims", @"organizations", @"birthday", @"note", @"photos", @"categories", @"urls"]];
	
	[[[ForgeApp sharedApp] viewController] dismissViewControllerHelper:^{
		[task success:data];
		me = nil;
	}];
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	// This should never happen
	[[[ForgeApp sharedApp] viewController] dismissViewControllerHelper:^{
		me = nil;
	}];
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[[[ForgeApp sharedApp] viewController] dismissViewControllerHelper:^{
		[task error:@"Contact selection cancelled" type:@"EXPECTED_FAILURE" subtype:nil];
		me = nil;
	}];
}


@end

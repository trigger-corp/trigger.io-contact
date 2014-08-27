//
//  contact_Delegate.h
//  Forge
//
//  Created by Connor Dunn on 14/03/2012.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface contact_Delegate : NSObject <ABPeoplePickerNavigationControllerDelegate, ABNewPersonViewControllerDelegate> {
	ForgeTask *task;
	contact_Delegate *me;
}

- (contact_Delegate*) initWithTask:(ForgeTask*)initTask;

@end

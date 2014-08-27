//
//  contact_API.h
//  Forge
//
//  Created by Connor Dunn on 14/03/2012.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface contact_API : NSObject

+ (void)select:(ForgeTask*)task;
+ (void)selectById:(ForgeTask*)task id:(NSString *)contactId;
+ (void)selectAll:(ForgeTask*)task fields:(NSArray*) fields;
+ (void)add:(ForgeTask*)task contact:(NSDictionary*) contact;

@end

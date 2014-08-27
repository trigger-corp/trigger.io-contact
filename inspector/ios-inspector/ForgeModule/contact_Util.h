//
//  contact_Util.h
//  ForgeTemplate
//
//  Created by James Brady on 05/10/2012.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface contact_Util : NSObject

+ (NSDictionary*) dictFrom:(ABRecordRef)contact withFields:(NSArray*)fields;
+ (ABRecordRef) personFrom:(NSDictionary *)contact;

@end

//
//  contact_Util.m
//  ForgeTemplate
//
//  Created by James Brady on 05/10/2012.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import "contact_Util.h"

@implementation contact_Util

+ (NSDictionary*) dictFrom:(ABRecordRef)contact withFields:(NSArray *)fields {
    NSDictionary *data = [[NSMutableDictionary alloc] init];
    
    [data setValue:[NSString stringWithFormat:@"%d", ABRecordGetRecordID(contact)] forKey:@"id"];
    
    NSString *displayName = @"";
    if (ABRecordCopyValue(contact, kABPersonPrefixProperty) != NULL) {
        displayName = [displayName stringByAppendingFormat:@"%@ ", (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonPrefixProperty)];
    }
    if (ABRecordCopyValue(contact, kABPersonFirstNameProperty) != NULL) {
        displayName = [displayName stringByAppendingFormat:@"%@ ", (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonFirstNameProperty)];
    }
    if (ABRecordCopyValue(contact, kABPersonMiddleNameProperty) != NULL) {
        displayName = [displayName stringByAppendingFormat:@"%@ ", (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonMiddleNameProperty)];
    }
    if (ABRecordCopyValue(contact, kABPersonLastNameProperty) != NULL) {
        displayName = [displayName stringByAppendingFormat:@"%@ ", (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonLastNameProperty)];
    }
    if (ABRecordCopyValue(contact, kABPersonSuffixProperty) != NULL) {
        displayName = [displayName stringByAppendingFormat:@"%@ ", (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonSuffixProperty)];
    }
    displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
    [data setValue:displayName forKey:@"displayName"];
	
	if ([fields containsObject:@"photos"]) {
		if (ABPersonHasImageData(contact)) {
			UIImage *image = [[UIImage alloc] initWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail)];
			NSData *imageData = UIImageJPEGRepresentation(image, 0.8 );
			
			NSString *base64Data = [imageData base64EncodingWithLineLength:0];
			
			[data setValue:[[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:
															 [NSString stringWithFormat:@"data:image/jpg;base64,%@", base64Data],
															 @"value",
															 [[NSNumber alloc] initWithBool:NO],
															 @"pref",
															 nil], nil] forKey:@"photos"];
		}
	}
    
	if ([fields containsObject:@"nickname"]) {
		[data setValue:(__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonNicknameProperty) forKey:@"nickname"];
	}
	
	if ([fields containsObject:@"note"]) {
		[data setValue:(__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonNoteProperty) forKey:@"note"];
	}
    
	if ([fields containsObject:@"birthday"]) {
		// TODO: Return as date
		[data setValue:[(__bridge_transfer NSDate *)ABRecordCopyValue(contact, kABPersonBirthdayProperty) description] forKey:@"birthday"];
	}
    
	if ([fields containsObject:@"name"]) {
		[data setValue:[[NSDictionary alloc] initWithObjectsAndKeys:
						(__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonLastNameProperty), @"familyName",
						[data objectForKey:@"displayName"], @"formatted",
						(__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonFirstNameProperty), @"givenName",
						(__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonPrefixProperty), @"honorificPrefix",
						(__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonSuffixProperty), @"honorificSuffix",
						(__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonMiddleNameProperty), @"middleName", nil] forKey:@"name"];
	}
	
	if ([fields containsObject:@"urls"]) {
		ABMultiValueRef urlMultiValue = ABRecordCopyValue(contact, kABPersonURLProperty);
		
		NSMutableArray *urls = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(urlMultiValue)];
		
		for (int x = 0; x < ABMultiValueGetCount(urlMultiValue); x++) {
			CFStringRef labelRef = ABMultiValueCopyLabelAtIndex(urlMultiValue, x);
			NSString *label = (__bridge_transfer NSString *)labelRef;
			
			
			// Specified label constants
			// https://www.pivotaltracker.com/story/show/33995229
			// http://www.iphonedevsdk.com/forum/iphone-sdk-development/97478-abpeoplepickernavigationcontroller-crash.html
			// Exchange can return NULL for labelRef
			if (labelRef != NULL) {
				if (CFStringCompare(labelRef, kABPersonHomePageLabel, 0) == kCFCompareEqualTo) {
					label = @"homepage";
				} else if (CFStringCompare(labelRef, kABWorkLabel, 0) == kCFCompareEqualTo) {
					label = @"work";
				} else if (CFStringCompare(labelRef, kABHomeLabel, 0) == kCFCompareEqualTo) {
					label = @"home";
				} else if (CFStringCompare(labelRef, kABOtherLabel, 0) == kCFCompareEqualTo) {
					label = @"other";
				}
			} else {
				label = @"other";
			}
			
			[urls addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:NO], @"pref", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(urlMultiValue, x), @"value", label, @"type", nil]];
		}
		[data setValue:urls forKey:@"urls"];
		CFRelease(urlMultiValue);
	}
    
    if ([fields containsObject:@"phoneNumbers"]) {
		ABMultiValueRef phoneMultiValue = ABRecordCopyValue(contact, kABPersonPhoneProperty);
		
		NSMutableArray *phones = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(phoneMultiValue)];
		
		for (int x = 0; x < ABMultiValueGetCount(phoneMultiValue); x++) {
			CFStringRef labelRef = ABMultiValueCopyLabelAtIndex(phoneMultiValue, x);
			NSString *label = (__bridge_transfer NSString *)labelRef;
			
			// Specified label constants
			if (labelRef != NULL) {
				if (CFStringCompare(labelRef, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
					label = @"mobile";
				} else if (CFStringCompare(labelRef, kABPersonPhoneIPhoneLabel, 0) == kCFCompareEqualTo) {
					label = @"iPhone";
				} else if (CFStringCompare(labelRef, kABPersonPhoneMainLabel, 0) == kCFCompareEqualTo) {
					label = @"main";
				} else if (CFStringCompare(labelRef, kABPersonPhoneHomeFAXLabel, 0) == kCFCompareEqualTo) {
					label = @"home_fax";
				} else if (CFStringCompare(labelRef, kABPersonPhoneWorkFAXLabel, 0) == kCFCompareEqualTo) {
					label = @"work_fax";
				} else if (CFStringCompare(labelRef, kABPersonPhonePagerLabel, 0) == kCFCompareEqualTo) {
					label = @"pager";
				} else if (CFStringCompare(labelRef, kABWorkLabel, 0) == kCFCompareEqualTo) {
					label = @"work";
				} else if (CFStringCompare(labelRef, kABHomeLabel, 0) == kCFCompareEqualTo) {
					label = @"home";
				} else if (CFStringCompare(labelRef, kABOtherLabel, 0) == kCFCompareEqualTo) {
					label = @"other";
				}
			} else {
				label = @"other";
			}
			
			[phones addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:NO], @"pref", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneMultiValue, x), @"value", label, @"type", nil]];
		}
		[data setValue:phones forKey:@"phoneNumbers"];
		CFRelease(phoneMultiValue);
	}
    
    if ([fields containsObject:@"emails"]) {
		ABMultiValueRef emailMultiValue = ABRecordCopyValue(contact, kABPersonEmailProperty);
		
		NSMutableArray *emails = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(emailMultiValue)];
		
		for (int x = 0; x < ABMultiValueGetCount(emailMultiValue); x++) {
			CFStringRef labelRef = ABMultiValueCopyLabelAtIndex(emailMultiValue, x);
			NSString *label = (__bridge_transfer NSString *)labelRef;
			
			if (labelRef != NULL) {
				if (CFStringCompare(labelRef, kABWorkLabel, 0) == kCFCompareEqualTo) {
					label = @"work";
				} else if (CFStringCompare(labelRef, kABHomeLabel, 0) == kCFCompareEqualTo) {
					label = @"home";
				} else if (CFStringCompare(labelRef, kABOtherLabel, 0) == kCFCompareEqualTo) {
					label = @"other";
				}
			} else {
				label = @"other";
			}
			
			[emails addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:NO], @"pref", (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailMultiValue, x), @"value", label, @"type", nil]];
		}
		[data setValue:emails forKey:@"emails"];
		CFRelease(emailMultiValue);
	}
    
    if ([fields containsObject:@"ims"]) {
		ABMultiValueRef imMultiValue = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);
		
		NSMutableArray *ims = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(imMultiValue)];
		
		for (int x = 0; x < ABMultiValueGetCount(imMultiValue); x++) {
			NSDictionary *dict = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(imMultiValue, x);
			
			[ims addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:NO], @"pref", [dict objectForKey:(__bridge_transfer NSString *)kABPersonInstantMessageUsernameKey], @"value", [dict objectForKey:(__bridge_transfer NSString *)kABPersonInstantMessageServiceKey], @"type", nil]];
		}
		[data setValue:ims forKey:@"ims"];
		CFRelease(imMultiValue);
	}
    
    if ([fields containsObject:@"organizations"]) {
		if ((__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonOrganizationProperty) != nil || (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonDepartmentProperty) != nil || (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonJobTitleProperty) != nil) {
			[data setValue:[[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:
															 (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonOrganizationProperty),
															 @"name",
															 (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonDepartmentProperty),
															 @"department",
															 (__bridge_transfer NSString *)ABRecordCopyValue(contact, kABPersonJobTitleProperty),
															 @"title",
															 nil], nil] forKey:@"organizations"];
		} else {
			[data setValue:[[NSArray alloc] init] forKey:@"organizations"];
		}
	}
    
    if ([fields containsObject:@"addresses"]) {
		ABMultiValueRef addressMultiValue = ABRecordCopyValue(contact, kABPersonAddressProperty);
		
		NSMutableArray *addresses = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(addressMultiValue)];
		
		for (int x = 0; x < ABMultiValueGetCount(addressMultiValue); x++) {
			CFStringRef labelRef = ABMultiValueCopyLabelAtIndex(addressMultiValue, x);
			NSString *label = (__bridge_transfer NSString *)labelRef;
			
			if (labelRef != NULL) {
				if (CFStringCompare(labelRef, kABWorkLabel, 0) == kCFCompareEqualTo) {
					label = @"work";
				} else if (CFStringCompare(labelRef, kABHomeLabel, 0) == kCFCompareEqualTo) {
					label = @"home";
				} else if (CFStringCompare(labelRef, kABOtherLabel, 0) == kCFCompareEqualTo) {
					label = @"other";
				}
			} else {
				label = @"other";
			}
			
			NSDictionary *dict = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(addressMultiValue, x);
			
			NSMutableDictionary *address = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
											[[NSNumber alloc] initWithBool:NO], @"pref",
											[dict objectForKey:(__bridge_transfer NSString *)kABPersonAddressStreetKey], @"streetAddress",
											[dict objectForKey:(__bridge_transfer NSString *)kABPersonAddressCityKey], @"locality",
											[dict objectForKey:(__bridge_transfer NSString *)kABPersonAddressStateKey], @"region",
											[dict objectForKey:(__bridge_transfer NSString *)kABPersonAddressZIPKey], @"postalCode",
											[dict objectForKey:(__bridge_transfer NSString *)kABPersonAddressCountryKey], @"country",
											label, @"type",
											nil];
			
			NSString *formatted = @"";
			if ([address objectForKey:@"streetAddress"]) {
				formatted = [formatted stringByAppendingFormat:@"%@\n", [address objectForKey:@"streetAddress"]];
			}
			if ([address objectForKey:@"locality"]) {
				formatted = [formatted stringByAppendingFormat:@"%@\n", [address objectForKey:@"locality"]];
			}
			if ([address objectForKey:@"region"]) {
				formatted = [formatted stringByAppendingFormat:@"%@\n", [address objectForKey:@"region"]];
			}
			if ([address objectForKey:@"postalCode"]) {
				formatted = [formatted stringByAppendingFormat:@"%@\n", [address objectForKey:@"postalCode"]];
			}
			if ([address objectForKey:@"country"]) {
				formatted = [formatted stringByAppendingFormat:@"%@\n", [address objectForKey:@"country"]];
			}
			formatted = [formatted stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			[address setValue:formatted forKey:@"formatted"];
			
			[addresses addObject:address];
		}
		[data setValue:addresses forKey:@"addresses"];
		CFRelease(addressMultiValue);
	}
	
    return data;
}

@end

//
//  contact_Util.m
//  ForgeTemplate
//
//  Created by James Brady on 05/10/2012.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import "contact_Util.h"

@implementation contact_Util


/**
 * Create a NSDictionary from an ABRecordRef
 */
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
		
        if (urlMultiValue) {
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
    }
    
    if ([fields containsObject:@"phoneNumbers"]) {
		ABMultiValueRef phoneMultiValue = ABRecordCopyValue(contact, kABPersonPhoneProperty);
		
        if (phoneMultiValue) {
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
    }
    
    if ([fields containsObject:@"emails"]) {
		ABMultiValueRef emailMultiValue = ABRecordCopyValue(contact, kABPersonEmailProperty);
	
        if (emailMultiValue) {
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
	}
    
    if ([fields containsObject:@"ims"]) {
		ABMultiValueRef imMultiValue = ABRecordCopyValue(contact, kABPersonInstantMessageProperty);

        if (imMultiValue) {
            NSMutableArray *ims = [[NSMutableArray alloc] initWithCapacity:ABMultiValueGetCount(imMultiValue)];
            
            for (int x = 0; x < ABMultiValueGetCount(imMultiValue); x++) {
                NSDictionary *dict = (__bridge_transfer NSDictionary *)ABMultiValueCopyValueAtIndex(imMultiValue, x);
                
                [ims addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithBool:NO], @"pref", [dict objectForKey:(__bridge_transfer NSString *)kABPersonInstantMessageUsernameKey], @"value", [dict objectForKey:(__bridge_transfer NSString *)kABPersonInstantMessageServiceKey], @"type", nil]];
            }
            [data setValue:ims forKey:@"ims"];
            CFRelease(imMultiValue);
        }
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
		
        if (addressMultiValue) {
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
	}
	
    return data;
}

+ (NSError *)contactError:(NSString *)description {
    
    NSDictionary *errorDetail =
        @{ NSLocalizedDescriptionKey: description };
    
    NSError *thisError =
        [NSError errorWithDomain:@"iOSContactDomain"
                            code:1
                        userInfo:errorDetail];
    
    return thisError;
}

+ (bool)mapElements:(ABRecordRef)newPerson
           workDict:(NSDictionary *)workDict
           elements:(NSArray *)elements
          error_out:(CFErrorRef *)error_out {
    bool result = YES;
    // Cycle over all of our elements, looking for hits within the workDict.
    
    for (NSArray *element in elements) {
        NSString *key = element[0];
        NSNumber *propNum = element[1];
        ABPropertyID prop = [propNum intValue];
        
        id value = workDict[key];
        
        // If we got a value...
        
        if (value) {
            // ...go ahead and stuff it into newPerson.
            result = ABRecordSetValue(newPerson,
                                      prop, (__bridge CFTypeRef)value,
                                      error_out);
            
            if (!result) {
                // Something went wrong; get outta here.
                break;
            }
        }
    }
    
    return result;
}

+ (bool)mapUnivalues:(ABRecordRef)newPerson
         contactDict:(NSDictionary *)contactDict
        propertyMaps:(NSArray *)propertyMaps
           error_out:(CFErrorRef *)error_out {
    bool result = YES;
    
    for (NSArray *map in propertyMaps) {
        NSString *workKey = map[0];
        NSArray *elements = map[1];
        
        // Assume that they want to look at the top-level dictionary...
        NSDictionary *workDict = contactDict;
        
        // ...then check to see if they gave a key.
        if ((id) workKey != [NSNull null]) {
            // Yup.  Shift workDict down.
            workDict = contactDict[workKey];
        }
        
        if (!workDict || ([workDict count] <= 0)) {
            // The dict they want to look at doesn't exist or is empty.
            // Skip it.
            continue;
        }
        
        result = [self mapElements:newPerson
                          workDict:workDict
                          elements:elements
                         error_out:error_out];
    }
    
    return result;
}

bool isPresent(NSString *str) {
    return (str && ((id)str != [NSNull null]) && ([str length] > 0));
}

+ (bool)mapMultiValues:(ABRecordRef)newPerson
           contactDict:(NSDictionary *)contactDict
     multipropertyMaps:(NSArray *)multipropertyMaps
             error_out:(CFErrorRef *)error_out {
    bool result = YES;
    
    for (NSArray *multiMap in multipropertyMaps) {
        NSString *workKey = multiMap[0];
        NSNumber *propNum = multiMap[1];
        NSString *defaultLabel = multiMap[2];
        NSDictionary *elements = multiMap[3];
        
        // Here, we MUST have a workKey...
        NSAssert(isPresent(workKey), @"workKey cannot be null");
        
        // ...and it's the name of an array, not of another dictionary.
        NSArray *workArray = contactDict[workKey];
        
        if (!workArray || ([workArray count] <= 0)) {
            // The array they want to look at doesn't exist or is empty.
            // Skip it.
            continue;
        }
        
        // OK.  Create a new multivalue...
        ABMutableMultiValueRef multiValue =
            ABMultiValueCreateMutable(kABMultiStringPropertyType);
        
        // ...and cycle over the workArray rather than the map this time.
        for (NSDictionary *workElement in workArray) {
            NSString *value = workElement[@"value"];
            NSString *type = workElement[@"type"];
            // ignore "pref" -- we don't support it.
            
            NSString *label = elements[type];
            
            if (!isPresent(label)) {
                // Not in the map.  Do we have a default?
                if (isPresent(defaultLabel)) {
                    // Yeah.  Use that.
                    label = defaultLabel;
                }
                else {
                    // If we have no label and no default, skip it.
                    continue;
                }
            }
            
            if (!isPresent(value)) {
                continue;
            }
            
            // OK, off we go.  Add to the multivalue.
            
            result =
                ABMultiValueAddValueAndLabel(multiValue,
                                             (__bridge CFTypeRef)value,
                                             (__bridge CFStringRef)label,
                                             NULL);
            
            if (!result) {
                // That ain't good.
                NSString *errStr =
                    [NSString stringWithFormat:@"couldn't add %@ %@ to contact",
                        workKey, label];
                
                NSError *thisError = [self contactError:errStr];
                *error_out = (__bridge CFErrorRef)thisError;
                break;
            }
        }
        
        if (result) {
            // Add it to the contact.
            result = ABRecordSetValue(newPerson, [propNum intValue],
                                      multiValue, error_out);
        }
        
        if (!result) {
            // Aarrrrgh.
            break;
        }
    }
    
    return result;
}

+ (ABRecordRef)contactCreateFrom:(NSDictionary *)dict
                       error_out:(CFErrorRef *)error_out {
    // WARNING WARNING WARNING!!
    //
    // You _MUST_ create newPerson _before_ setting up the maps below.
    // Read the comments above the maps for more, but FFS don't waste
    // an hour or two of your life, like I just did, getting this wrong.
    
    bool result = YES;
    
    // Create a new person record.
    ABRecordRef newPerson = ABPersonCreate();   // MUST HAPPEN BEFORE MAPS -- SEE COMMENTS FOR MAPS
    
    if (!newPerson) {
        NSError *thisError =
        [self contactError:@"couldn't allocate new ABRecord"];
        
        *error_out = (__bridge CFErrorRef)thisError;
        
        result = NO;
    }
    
    // You might think these maps could be statics, but the @[] construction
    // is actually a run-time thing, not a compile-time thing.  Even _worse_,
    // though: the !*&#!*@&# kAB...Property elements are _0_ before you call
    // something that calls ABAddressBookCreate().
    //
    // I just blew hours of my life tracking that down -- oh my GOD how
    // incredibly infuriating.  Hey Apple -- who the !*@&#!*& designed this
    // POS?  And why in the name of all that is holy is it not documented
    // in big red letters in the ABPerson reference?  FFS.
    
    NSArray *propertyMaps =
        @[
          @[ [NSNull null],
             @[ @[ @"note", @(kABPersonNoteProperty) ],
                @[ @"nickname", @(kABPersonNicknameProperty) ],
                ],
             ],
          @[ @"name",
             @[ @[ @"givenName", @(kABPersonFirstNameProperty) ],
                @[ @"familyName", @(kABPersonLastNameProperty) ],
                @[ @"honorificPrefix", @(kABPersonPrefixProperty) ],
                @[ @"honorificSuffix", @(kABPersonSuffixProperty) ],
                @[ @"middleName", @(kABPersonMiddleNameProperty) ],
                ],
             ],
          ];
    
    // multiPropertyMaps is an array of subarrays:
    //
    // @[ JSON-key, kABPerson-property, default-label, map ]
    //
    // where the map is a dict mapping an inner JSON key to the
    // kABPerson-multi-string-label.
    //
    // The default-label may be an NSNull to mean 'preserve the JSON key
    // as the value if it's not found.'
    
    NSArray *multipropertyMaps =
        @[
          @[ @"phoneNumbers", @(kABPersonPhoneProperty), @"mobile",
             @{ @"mobile": (__bridge NSString *) kABPersonPhoneMobileLabel,
                @"iPhone": (__bridge NSString *) kABPersonPhoneIPhoneLabel,
                @"main": (__bridge NSString *) kABPersonPhoneMainLabel,
                @"home_fax": (__bridge NSString *) kABPersonPhoneHomeFAXLabel,
                @"work_fax": (__bridge NSString *) kABPersonPhoneWorkFAXLabel,
                @"pager": (__bridge NSString *) kABPersonPhonePagerLabel,
                @"work": (__bridge NSString *) kABWorkLabel,
                @"home": (__bridge NSString *) kABHomeLabel,
                @"other": (__bridge NSString *) kABOtherLabel,
                },
             ],
          @[ @"emails", @(kABPersonEmailProperty), @"home",
             @{ @"work": (__bridge NSString *) kABWorkLabel,
                @"home": (__bridge NSString *) kABHomeLabel,
                @"other": (__bridge NSString *) kABOtherLabel,
                },
             ],
          @[ @"urls", @(kABPersonEmailProperty), @"other",
             @{ @"homepage": (__bridge NSString *) kABPersonHomePageLabel,
                @"work": (__bridge NSString *) kABWorkLabel,
                @"home": (__bridge NSString *) kABHomeLabel,
                @"other": (__bridge NSString *) kABOtherLabel,
                },
             ],
          ];
    
    NSArray *orgMap =
        @[ @[ @"name", @(kABPersonOrganizationProperty) ],
           @[ @"department", @(kABPersonDepartmentProperty) ],
           @[ @"title", @(kABPersonJobTitleProperty) ] ];
    
    if (result) {
        result = [self mapUnivalues:newPerson
                        contactDict:dict
                       propertyMaps:propertyMaps
                          error_out:error_out];
    }
    
    if (result) {
        result = [self mapMultiValues:newPerson
                          contactDict:dict
                    multipropertyMaps:multipropertyMaps
                            error_out:error_out];
    }
    
    if (result) {
        // Organizations are weird, since that's an array of dicts where
        // each dict looks like a univalue.  Do them by hand.
        
        NSArray *orgs = dict[@"organizations"];
        
        if (orgs && ([orgs count] > 0)) {
            // Ignore all but the first org.
            result = [self mapElements:newPerson
                              workDict:orgs[0]
                              elements:orgMap
                             error_out:error_out];
        }
    }
    
    if (result) {
        // Birthday is special, since it has to be a date, not a string,
        // and there are a bunch of ways to format birthdays.  Here are a few.
        // (Man, handling dates sucks.)

        NSArray *bDayFormats =
            @[ @"yyyy-MM-dd HH:mm:ss Z",
               @"yyyy-MM-dd HH:mm:ss",
               @"yyyy-MM-dd"
              ];
        
        NSString *bDayString = dict[@"birthday"];
        
        if (bDayString && ([bDayString length] > 0)) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            NSDate *birthday = nil;
            
            for (int i = 0; i < [bDayFormats count]; i++) {
                NSString *fmt = [bDayFormats objectAtIndex:i];
                
                
                [format setDateFormat:fmt];
                birthday = [format dateFromString:bDayString];

                if (birthday) {
//                    NSLog(@"parsed %@ with %@", bDayString, fmt);
                    break;
                }
//                else {
//                    NSLog(@"couldn't parse %@ with %@", bDayString, fmt);
//                }
            }

            if (birthday) {
                result = ABRecordSetValue(newPerson,
                                          kABPersonBirthdayProperty,
                                          (__bridge CFTypeRef)birthday,
                                          error_out);
            }
            else {
                NSLog(@"couldn't convert %@ to NSDate", bDayString);
                // Not a fatal error, just keep going.
            }
        }
    }
    
cleanup:
    if (!result) {
        // Something went wrong.  Release our person...
        if (newPerson) CFRelease(newPerson);
        
        // ...and return nil.
        newPerson = nil;
    }
    
    return newPerson;
}

@end

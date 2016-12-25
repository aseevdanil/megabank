//
//  MBObject.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBObject.h"



@implementation NSArray (MBObject)


- (NSUInteger)indexOfObjectWithId:(NSString*)objectId
{
	for (NSUInteger i = 0; i < self.count; ++i)
	{
		id<MBObject> object = (id<MBObject>)[self objectAtIndex:i];
		if (DA_EQUAL_STRINGS(objectId, object.objectId))
			return i;
	}
	return NSNotFound;
}


@end



NSString *QueryString(NSDictionary *parameters, NSStringEncoding encoding)
{
	if (!parameters)
		return nil;
	NSMutableString *query = [NSMutableString string];
	[parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
	 {
		 DASSERT([key isKindOfClass:[NSString class]]);
		 DASSERT([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]);
		 NSString *objDesc = [obj isKindOfClass:[NSString class]] ? (NSString*) obj : [obj description];
		 [query appendFormat:@"%@%@%@%@", query.length > 0 ? @"&" : @"", UrlEncodedString((NSString*) key, encoding), @"=", UrlEncodedString(objDesc, encoding)];
	 }];
	return query;
}


NSString *UrlEncodedString(NSString *string,  NSStringEncoding encoding)
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	static const CFStringRef kCharactersToBeEscaped = CFSTR(":/?&=;+!@#$()~'");
	static const CFStringRef kCharactersToLeaveUnescaped = CFSTR("[].");
	return (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) string, kCharactersToLeaveUnescaped, kCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding)));
#pragma GCC diagnostic pop
}

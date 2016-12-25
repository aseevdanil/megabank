//
//  MBObject.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



// MBObject


@protocol MBObject
@property (nonatomic, copy, readonly) NSString *objectId;
@end


@interface NSArray (MBObject)

- (NSUInteger)indexOfObjectWithId:(NSString*)objectId;

@end



@protocol MBAPIMappable
- (void)mappingFromAPIResponse:(NSDictionary*)response;
@end


FOUNDATION_STATIC_INLINE CLLocationCoordinate2D CLLocationCoordinate2DFromAPIResponse(NSDictionary *response)
{
	DASSERT(response && [response isKindOfClass:[NSDictionary class]]);
	NSNumber *locationLatitude = response && [response isKindOfClass:[NSDictionary class]] ? (NSNumber*)[response objectForKey:@"latitude"] : nil;
	NSNumber *locationLongitude = response && [response isKindOfClass:[NSDictionary class]] ? (NSNumber*)[response objectForKey:@"longitude"] : nil;
	return locationLatitude && locationLongitude ? CLLocationCoordinate2DMake([locationLatitude doubleValue], [locationLongitude doubleValue]) : kCLLocationCoordinate2DInvalid;
}



// Helpers


typedef NS_ENUM(NSUInteger, MBErrorNotificationLevel)
{
	MBErrorNotificationLevelDefault,
	MBErrorNotificationLevelSilent,
};



@protocol MBContextReceiver
@optional
- (BOOL)putContext:(id)context;
@end


@protocol MBOperation <NSObject>
- (void)cancel;
@end



NSString *QueryString(NSDictionary *parameters, NSStringEncoding encoding);
NSString *UrlEncodedString(NSString *string,  NSStringEncoding encoding);

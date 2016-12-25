//
//  MBMPoint.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBMPoint.h"



@implementation MBMPoint


@dynamic partner;


- (CLLocationCoordinate2D)location
{
	[self willAccessValueForKey:@"locationLatitude"];
	NSNumber *locationLatitude = (NSNumber*)[self primitiveValueForKey:@"locationLatitude"];
	[self didAccessValueForKey:@"locationLatitude"];
	
	[self willAccessValueForKey:@"locationLongitude"];
	NSNumber *locationLongitude = (NSNumber*)[self primitiveValueForKey:@"locationLongitude"];
	[self didAccessValueForKey:@"locationLongitude"];
	
	return locationLatitude && locationLongitude ? CLLocationCoordinate2DMake([locationLatitude doubleValue], [locationLongitude doubleValue]) : kCLLocationCoordinate2DInvalid;
}


- (void)setLocation:(CLLocationCoordinate2D)location
{
	BOOL valid = CLLocationCoordinate2DIsValid(location);
	[self willChangeValueForKey:@"locationLatitude"];
	[self setPrimitiveValue:valid ? [NSNumber numberWithDouble:location.latitude] : nil forKey:@"locationLatitude"];
	[self didChangeValueForKey:@"locationLatitude"];
	
	[self willChangeValueForKey:@"locationLongitude"];
	[self setPrimitiveValue:valid ? [NSNumber numberWithDouble:location.longitude] : nil forKey:@"locationLongitude"];
	[self didChangeValueForKey:@"locationLongitude"];
}


@dynamic address;
@dynamic schedule;


@end



@implementation MBMPoint (MBAPIMappable)


- (void)mappingFromAPIResponse:(NSDictionary*)response
{
	DASSERT(response);
	self.address = (NSString*)[response objectForKey:@"fullAddress"];
	self.schedule = (NSString*)[response objectForKey:@"workHours"];
}


@end



@implementation MBMPoint (MB)


+ (MBMPoint*)MBPreparePartnerPoint:(MBMPartner*)partner withLocation:(CLLocationCoordinate2D)pointLocation inContext:(NSManagedObjectContext*)context
{
	DASSERT(CLLocationCoordinate2DIsValid(pointLocation));
	DASSERT(partner);
	if (!partner)
		return nil;
	MBMPoint *point = [MBMPoint MB_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"partner == %@ AND locationLatitude == %f AND locationLongitude == %f", partner, pointLocation.latitude, pointLocation.longitude] inContext:context];
	if (!point)
	{
		point = [MBMPoint MB_createInContext:context];
		point.location = pointLocation;
		point.partner = partner;
	}
	return point;
}


@end

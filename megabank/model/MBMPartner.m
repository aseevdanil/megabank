//
//  MBMPartner.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBMPartner.h"



@implementation MBMPartner


@dynamic pid;
@dynamic name;
@dynamic logo;
@dynamic url;


- (NSURL*)logoURL
{
	return [NSURL MBImageURLFromImageUrlString:self.logo];
}


@dynamic points;


- (NSString*)objectId
{
	return self.pid;
}


@end



@implementation MBMPartner (MBAPIMappable)


- (void)mappingFromAPIResponse:(NSDictionary*)response
{
	DASSERT(response);
	DASSERT([self.pid isEqualToString:(NSString*)[response objectForKey:@"id"]]);
	self.name = (NSString*)[response objectForKey:@"name"];
	self.logo = (NSString*)[response objectForKey:@"picture"];
	self.url = (NSString*)[response objectForKey:@"url"];
}


@end



@implementation MBMPartner (MB)


+ (MBMPartner*)MBPartnerWithPid:(NSString*)pid inContext:(NSManagedObjectContext*)context
{
	if (!pid)
		return nil;
	NSFetchRequest *request = [self MB_requestForProperty:@"pid" withValue:pid inContext:context];
	request.returnsObjectsAsFaults = NO;
	return [request MB_requestedFirstInContext:context];
}


+ (MBMPartner*)MBCreatePartnerWithPid:(NSString*)pid inContext:(NSManagedObjectContext *)context
{
	DASSERT(pid);
	MBMPartner *partner = [self MB_createInContext:context];
	partner.pid = pid;
	return partner;
}


+ (MBMPartner*)MBPreparePartnerWithPid:(NSString*)pid inContext:(NSManagedObjectContext*)context
{
	DASSERT(pid);
	if (!pid)
		return nil;
	MBMPartner *partner = [self MBPartnerWithPid:pid inContext:context];
	if (!partner)
		partner = [self MBCreatePartnerWithPid:pid inContext:context];
	return partner;
}


@end

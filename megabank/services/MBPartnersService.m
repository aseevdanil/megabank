//
//  MBPartnersService.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPartnersService.h"



@interface MBPartnersService ()
{
	NSTimeInterval _partnersUpdateTime;
	id<MBConnectOperation> _partnersConnection;
}

+ (uint_least32_t)partnersChecksum;
+ (void)setPartnersChecksum:(uint_least32_t)checksum;

- (BOOL)isPartnersDeprecate;
- (void)requestPartners;

@end


@implementation MBPartnersService


SINGLETON_IMPL(sharedService)


- (instancetype)init
{
	if ((self = [super init]))
	{
		_launched = _partnersLoaded = NO;
		_partnersUpdateTime = 0.;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectServiceDidChangeActive:) name:MBConnectServiceDidChangeActiveNotification object:nil];
	}
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MBConnectServiceDidChangeActiveNotification object:nil];
	MBCONNECTIONRELEASE(_partnersConnection)
}


- (void)launch
{
	if (_launched)
		return;
	_launched = YES;
	_partnersLoaded = [MBPartnersService partnersChecksum] != 0;
	if (_partnersLoaded)
		[[NSNotificationCenter defaultCenter] postNotificationName:MBPartnersServicePartnersLoadedDidChangeNotification object:nil userInfo:nil];
	if ([MBConnectService sharedService].isActive)
	{
		if ([self isPartnersDeprecate] && !_partnersConnection)
			[self requestPartners];
	}
}


- (void)stop
{
	[MBPartnersService setPartnersChecksum:0];
	if (!_launched)
		return;
	_launched = NO;
	MBCONNECTIONRELEASE(_partnersConnection)
	_partnersUpdateTime = 0.;
	if (_partnersLoaded)
	{
		_partnersLoaded = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:MBPartnersServicePartnersLoadedDidChangeNotification object:nil userInfo:nil];
	}
}


- (BOOL)isPartnersLoaded
{
	return _partnersLoaded;
}


static NSString *const kMBPartnersService_PartnersChecksum = @"MBPartnersService.partnersChecksum";


+ (uint_least32_t)partnersChecksum
{
	return (uint_least32_t)[[NSUserDefaults standardUserDefaults] integerForKey:kMBPartnersService_PartnersChecksum];
}


+ (void)setPartnersChecksum:(uint_least32_t)checksum
{
	if (checksum)
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInt:checksum] forKey:kMBPartnersService_PartnersChecksum];
	else
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kMBPartnersService_PartnersChecksum];
}


- (BOOL)isLaunched
{
	return _launched;
}


- (void)connectServiceDidChangeActive:(NSNotification*)notification
{
	if (_launched && [MBConnectService sharedService].isActive)
	{
		if ([self isPartnersDeprecate] && !_partnersConnection)
			[self requestPartners];
	}
}


- (BOOL)isPartnersDeprecate
{	// Не хочу перезапрашивать партнеров очень часто, так как их список изменяется редко
	return !_partnersUpdateTime || (_partnersUpdateTime < [NSDate timeIntervalSinceReferenceDate] - 4 * DA_HOUR);
}


- (void)_updatePartnersWithResponse:(id)response checksum:(uint_least32_t)checksum
{
	[theApp saveConcurrency:^(NSManagedObjectContext *localContext)
	 {
		 if (checksum != [MBPartnersService partnersChecksum])
		 {
			 DASSERT(response && [response isKindOfClass:[NSArray class]]);
			 if (!response || ![response isKindOfClass:[NSArray class]])
				 return;
			 NSMutableSet *partners = [[NSMutableSet alloc] initWithCapacity:((NSArray*) response).count];
			 for (NSDictionary *partnerDictionary in (NSArray*) response)
			 {
				 DASSERT(partnerDictionary && [partnerDictionary isKindOfClass:[NSDictionary class]]);
				 NSString *pid = (NSString*)[partnerDictionary objectForKey:@"id"];
				 MBMPartner *partner = [MBMPartner MBPreparePartnerWithPid:pid inContext:localContext];
				 [partner mappingFromAPIResponse:partnerDictionary];
				 [partners addObject:partner];
			 }
			 [MBMPartner MB_deleteWithPredicate:[NSPredicate predicateWithFormat:@"NOT SELF IN %@", partners] inContext:localContext];
		 }
	 }
				 completion:^
	 {
		 if (_launched)
		 {
			 [MBPartnersService setPartnersChecksum:checksum];
			 _partnersUpdateTime = [NSDate timeIntervalSinceReferenceDate];
			 if (!_partnersLoaded)
			 {
				 _partnersLoaded = YES;
				 [[NSNotificationCenter defaultCenter] postNotificationName:MBPartnersServicePartnersLoadedDidChangeNotification object:nil userInfo:nil];
			 }
		 }
	 }];
}


- (void)requestPartners
{
	DASSERT(_launched);
	if (!_launched)
		return;
	
	MBCONNECTIONRELEASE(_partnersConnection)
	typeof(self) __weak weakSelf = self;
	_partnersConnection = [[MBConnectService sharedService] connectWithMethod:GET function:kMBAPI_Pertners andParameters:[NSDictionary dictionaryWithObject:@"Credit" forKey:@"accountType"]
																	   options:MBConnectOptionPermanently completionHandler:^(id<MBConnectOperation> operation, id response, NSError *error)
							{
								typeof(self) strongSelf = weakSelf;
								if (strongSelf)
								{
									if (error)
									{
										[theApp processError:error notificationLevel:MBErrorNotificationLevelSilent];
									}
									else
									{
										NSNumber *responseChecksum = (NSNumber*)[operation.userInfo objectForKey:kMBConnectOperationResponseChecksumKey];
										[strongSelf _updatePartnersWithResponse:response checksum:responseChecksum ? [responseChecksum unsignedIntValue] : 0];
									}
									[[NSOperationQueue mainQueue] addOperationWithBlock:^
									 {
										 if (operation == strongSelf->_partnersConnection)
											 MBCONNECTIONRELEASE(strongSelf->_partnersConnection)
									 }];
								}
							}];
	_partnersConnection.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kMBConnectOperationComputeResponseChecksumKey];
}


@end


NOTIFICATION_IMPL(MBPartnersServicePartnersLoadedDidChangeNotification)

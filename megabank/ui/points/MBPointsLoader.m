//
//  MBPointsLoader.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsLoader.h"



/*
 Логика такая: запрашиваю очередные точки только когда приложение активно (запрос не permanent).
 Ведь загружать точки когда приложение свернуто, не имеет смысла - скорее всего при следующей активации приложения,
 местоположение юзера сильно изменится, поэтому эти точки уже будут не актуальны!
 */


@interface MBPointsLoader ()

- (void)startLoadConnection;

@end


@implementation MBPointsLoader


@synthesize function = _function;


- (instancetype)initWithLoadFunction:(NSString*)function
{
	if ((self = [super init]))
	{
		_function = function;
		_locationCoordinate = kCLLocationCoordinate2DInvalid;
		_locationRadius = 0.;
		_locationLoaded = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectServiceDidChangeActive:) name:MBConnectServiceDidChangeActiveNotification object:nil];
	}
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MBConnectServiceDidChangeActiveNotification object:nil];
	MBCONNECTIONRELEASE(_connection)
}


- (void)connectServiceDidChangeActive:(NSNotification*)notification
{
	if (!CLLocationCoordinate2DIsValid(_locationCoordinate) || _locationRadius == 0.)
		return;

	if (!_connection && !_locationLoaded)
	{
		if ([MBConnectService sharedService].isActive)
			[self startLoadConnection];
	}
}


- (void)loadInLocation:(CLLocationCoordinate2D)locationCoordinate radius:(CLLocationDistance)locationRadius
{
	if (!CLLocationCoordinate2DEqualToLocationCoordinate2D(locationCoordinate, _locationCoordinate))
	{
		MBCONNECTIONRELEASE(_connection)
		_locationLoaded = NO;
		_locationCoordinate = locationCoordinate;
	}
	if (!CLLocationCoordinate2DIsValid(_locationCoordinate))
	{
		MBCONNECTIONRELEASE(_connection)
		_locationRadius = 0.;
		_locationLoaded = NO;
		return;
	}
	if (_locationRadius < locationRadius)
	{
		MBCONNECTIONRELEASE(_connection)
		_locationLoaded = NO;
		_locationRadius = locationRadius;
	}
	if (_locationRadius < 1000.)
		_locationRadius = 1000.;
	
	if (!_connection && !_locationLoaded)
	{
		if ([MBConnectService sharedService].isActive)
			[self startLoadConnection];
	}
}


- (void)_handleLoadConnectionResponse:(NSArray*)response
{
	[theApp saveConcurrency:^(NSManagedObjectContext *localContext)
	 {
		 DASSERT(response && [response isKindOfClass:[NSArray class]]);
		 if (!response || ![response isKindOfClass:[NSArray class]])
			 return;
		 NSMutableSet *points = [[NSMutableSet alloc] initWithCapacity:((NSArray*) response).count];
		 for (NSDictionary *pointDictionary in (NSArray*) response)
		 {
			 DASSERT(pointDictionary && [pointDictionary isKindOfClass:[NSDictionary class]]);
			 NSString *pid = (NSString*)[pointDictionary objectForKey:@"partnerName"];
			 MBMPartner *partner = [MBMPartner MBPartnerWithPid:pid inContext:localContext];
			 if (partner)	// Добавляем точку только к существующему партнеру, нам ведь не нужны "потерявшиеся" точки
			 {
				 CLLocationCoordinate2D location = CLLocationCoordinate2DFromAPIResponse((NSDictionary*)[pointDictionary objectForKey:@"location"]);
				 if (CLLocationCoordinate2DIsValid(location))
				 {
					 MBMPoint *point = [MBMPoint MBPreparePartnerPoint:partner withLocation:location inContext:localContext];
					 [point mappingFromAPIResponse:pointDictionary];
					 [points addObject:point];
				 }
			 }
		 }
		 [MBMPoint MB_deleteWithPredicate:[NSPredicate predicateWithFormat:@"NOT SELF IN %@", points] inContext:localContext];
	 }
				 completion:nil];
	_locationLoaded = YES;
}


- (void)startLoadConnection
{
	DASSERT([MBConnectService sharedService].isActive);
	DASSERT(!_connection && !_locationLoaded);
	MBCONNECTIONRELEASE(_connection)
	
	DASSERT(CLLocationCoordinate2DIsValid(_locationCoordinate) && _locationRadius > 0.);
	typeof(self) __weak weakSelf = self;
	_connection = [[MBConnectService sharedService] connectWithMethod:GET function:_function andParameters:[NSDictionary dictionaryWithObjectsAndKeys:
																											[NSNumber numberWithFloat:(float) _locationCoordinate.latitude], @"latitude",
																											[NSNumber numberWithFloat:(float) _locationCoordinate.longitude], @"longitude",
																											[NSNumber numberWithUnsignedInt:(unsigned int) _locationRadius], @"radius",
																											nil]
															  options:MBConnectOptionCompletionOnMainQueue completionHandler:^(id<MBConnectOperation> operation, id response, NSError *error)
				   {
					   typeof(self) strongSelf = weakSelf;
					   if (strongSelf)
					   {
						   if (error)
							   [theApp processError:error notificationLevel:MBErrorNotificationLevelSilent];
						   else
							   [strongSelf _handleLoadConnectionResponse:response];
						   MBCONNECTIONRELEASE(strongSelf->_connection)
					   }
				   }];
}


@end

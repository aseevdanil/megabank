//
//  MBPointsModel.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsModel.h"

#import "MBPointsController.h"
#import "MBPointsLoader.h"



@interface MBPointsModel () <MBPointsControllerChangeObserver>
{
	MBPointsController *_pointsController;
	MBPointsLoader *_pointsLoader;
	CLLocationCoordinate2D _location;
	id<MBPointsModelDelegate> __weak _delegate;
	unsigned int _resumed : 1;
}

@end


@implementation MBPointsModel


@synthesize location = _location;
@synthesize delegate = _delegate;


- (instancetype)initWithPointsRequest:(NSFetchRequest*)pointsRequest andLoadFunction:(NSString*)pointsLoadFunction
{
	if ((self = [super init]))
	{
		_location = kCLLocationCoordinate2DInvalid;
		_pointsController = [[MBPointsController alloc] initWithPointsRequest:pointsRequest];
		_pointsController.changeObserver = self;
		_pointsLoader = [[MBPointsLoader alloc] initWithLoadFunction:pointsLoadFunction];
		
		_resumed = [MBPartnersService sharedService].isPartnersLoaded;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(partnersServicePartnersLoadedDidChange:) name:MBPartnersServicePartnersLoadedDidChangeNotification object:nil];
		
		CLLocation *location = [MBLocationService isGeolocationAvailable:NULL] && [MBLocationService isGeolocationEnabled:NULL] ? [MBLocationService sharedService].location : nil;
		CLLocationCoordinate2D locationCoordinate = location ? location.coordinate : kCLLocationCoordinate2DInvalid;
		if (CLLocationCoordinate2DIsValid(locationCoordinate))
			_location = locationCoordinate;
		_pointsController.locationCenter = _location;
		if (_resumed)
			[_pointsLoader loadInLocation:_location radius:0.];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationServiceDidUpdateLocation:) name:MBLocationServiceDidUpdateLocationNotification object:nil];
	}
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MBLocationServiceDidUpdateLocationNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MBPartnersServicePartnersLoadedDidChangeNotification object:nil];
}


- (NSFetchRequest*)pointsRequest
{
	return _pointsController.pointsRequest;
}


- (NSString*)pointsLoadFunction
{
	return _pointsLoader.function;
}


- (BOOL)isResumed
{
	return _resumed;
}


- (void)partnersServicePartnersLoadedDidChange:(NSNotification*)notification
{
	BOOL loaded = [MBPartnersService sharedService].isPartnersLoaded;
	if (loaded != _resumed)
	{
		_resumed = loaded;
		if (_resumed)
		{
			if (CLLocationCoordinate2DIsValid(_location))
				[_pointsLoader loadInLocation:_location radius:0.];
		}
		else
		{
			[_pointsLoader loadInLocation:kCLLocationCoordinate2DInvalid radius:0.];
		}
		id strongDelegate = _delegate;
		if (strongDelegate)
			[strongDelegate pointsModelResumedDidChange:self];
	}
}


- (void)locationServiceDidUpdateLocation:(NSNotification*)notification
{
	CLLocation *location = (CLLocation*)[notification.userInfo objectForKey:MBLocationServiceLocation];
	CLLocationCoordinate2D locationCoordinate = location ? location.coordinate : kCLLocationCoordinate2DInvalid;
	BOOL locationChanged = NO;
	if (CLLocationCoordinate2DIsValid(locationCoordinate))
	{
		if (!CLLocationCoordinate2DEqualToLocationCoordinate2D(locationCoordinate, _location))
		{
			_location = locationCoordinate;
			locationChanged = YES;
		}
	}
	else
	{
		if (CLLocationCoordinate2DIsValid(_location))
		{
			_location = kCLLocationCoordinate2DInvalid;
			locationChanged = YES;
		}
	}
	if (locationChanged)
	{
		_pointsController.locationCenter = _location;
		if (_resumed)
			[_pointsLoader loadInLocation:_location radius:0.];
		id strongDelegate = _delegate;
		if (strongDelegate)
			[strongDelegate pointsModelLocationDidChange:self];
	}
}


- (void)pointsController:(MBPointsController*)pointsController didChangePointsAnnotations:(NSArray<id<MBPointsAnnotation>>*)updatedPointsAnnotations :(NSArray<id<MBPointsAnnotation>>*)deletedPointsAnnotations :(NSArray<id<MBPointsAnnotation>>*)insertedPointsAnnotations
{
	DASSERT(CLLocationCoordinate2DIsValid(_location));
	id strongDelegate = _delegate;
	if (strongDelegate)
		[strongDelegate pointsModel:self didChangePointsAnnotations:updatedPointsAnnotations :deletedPointsAnnotations :insertedPointsAnnotations];
}


- (double)conglomerateRadius
{
	return _pointsController.conglomerateRadius;
}


- (void)setConglomerateRadius:(double)conglomerateRadius
{
	_pointsController.conglomerateRadius = conglomerateRadius;
}


- (NSArray<id<MBPointsAnnotation>>*)pointsAnnotations
{
	return _pointsController.pointsAnnotations;
}


- (void)loadPointsInRadius:(CLLocationDistance)radius
{
	if (_resumed)
		[_pointsLoader loadInLocation:_location radius:radius];
}


@end

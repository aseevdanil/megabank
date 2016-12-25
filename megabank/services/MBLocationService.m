//
//  MBLocationService.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBLocationService.h"



@interface MBLocationService () <CLLocationManagerDelegate>

@end


@implementation MBLocationService


#pragma mark Base


SINGLETON_IMPL(sharedService)


@synthesize location = _location;


- (instancetype)init
{
	if ((self = [super init]))
	{
		_launched = NO;
		if ([MBLocationService isGeolocationAvailable:NULL])
		{
			_locationManager = [[CLLocationManager alloc] init];
			_locationManager.delegate = self;
		}
	}
	return self;
}


- (void)launch
{
	if (_launched)
		return;
	_launched = YES;
	if (_locationManager)
	{
		NSError *error = nil;
		CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
		switch (authorizationStatus)
		{
			case kCLAuthorizationStatusNotDetermined:
				[_locationManager requestWhenInUseAuthorization];
				break;
			case kCLAuthorizationStatusAuthorizedAlways:
			case kCLAuthorizationStatusAuthorizedWhenInUse:
				[_locationManager startMonitoringSignificantLocationChanges];
				if (!_location)
				{
					_location = _locationManager.location;
					if (_location)
						[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidUpdateLocationNotification object:nil userInfo:_location ? [NSDictionary dictionaryWithObject:_location forKey:MBLocationServiceLocation] : nil];
				}
				break;
			case kCLAuthorizationStatusRestricted:
				error = [NSError MBGeolocationRestrictedLocationServiceError];
				break;
			case kCLAuthorizationStatusDenied:
				error = [NSError MBGeolocationDeniedLocationServiceError];
				break;
			default:
				break;
		}
		[theApp processError:error];
	}
}


- (void)stop
{
	if (!_launched)
		return;
	_launched = NO;
	if (_location)
	{
		_location = nil;
		[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidUpdateLocationNotification object:nil userInfo:nil];
	}
}


- (BOOL)isLaunched
{
	return _launched;
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	DASSERT(manager == _locationManager);
	switch (status)
	{
		case kCLAuthorizationStatusRestricted:
		case kCLAuthorizationStatusDenied:
			[_locationManager stopMonitoringSignificantLocationChanges];
			[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidChangeGeolocationEnabledNotification object:nil userInfo:nil];
			if (_location)
			{
				_location = nil;
				[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidUpdateLocationNotification object:nil userInfo:nil];
			}
			break;
		case kCLAuthorizationStatusAuthorizedAlways:
		case kCLAuthorizationStatusAuthorizedWhenInUse:
			[_locationManager startMonitoringSignificantLocationChanges];
			if (!_location)
			{
				_location = _locationManager.location;
				if (_location)
					[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidUpdateLocationNotification object:nil userInfo:_location ? [NSDictionary dictionaryWithObject:_location forKey:MBLocationServiceLocation] : nil];
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidChangeGeolocationEnabledNotification object:nil userInfo:nil];
			break;
		case kCLAuthorizationStatusNotDetermined:
		default:
			return;
	}
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	DASSERT(manager == _locationManager);
	if ([[error domain] isEqualToString:kCLErrorDomain])
	{
		switch ([error code])
		{
			case kCLErrorDenied:
				[_locationManager stopMonitoringSignificantLocationChanges];
				[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidChangeGeolocationEnabledNotification object:nil userInfo:nil];
				if (_location)
				{
					_location = nil;
					[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidUpdateLocationNotification object:nil userInfo:nil];
				}
				break;
		}
	}
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	_location = (CLLocation*)[locations lastObject];
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLocationServiceDidUpdateLocationNotification object:nil userInfo:_location ? [NSDictionary dictionaryWithObject:_location forKey:MBLocationServiceLocation] : nil];
}


#pragma mark System Geolocation


+ (BOOL)isGeolocationAvailable:(NSError**)perror
{
	if (![CLLocationManager significantLocationChangeMonitoringAvailable])
	{
		if (perror)
			*perror = [NSError MBGeolocationNotAvailableLocationServiceError];
		return NO;
	}
	return YES;
}


+ (BOOL)isGeolocationEnabled:(NSError**)perror
{
	if (![CLLocationManager locationServicesEnabled] || ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse))
	{
		if (perror)
		{
			CLAuthorizationStatus authorizationStatus = [CLLocationManager locationServicesEnabled] ? [CLLocationManager authorizationStatus] : kCLAuthorizationStatusDenied;
			*perror = authorizationStatus == kCLAuthorizationStatusDenied ? [NSError MBGeolocationDeniedLocationServiceError] : [NSError MBGeolocationRestrictedLocationServiceError];
		}
		return NO;
	}
	return YES;
}


@end


NOTIFICATION_IMPL(MBLocationServiceDidChangeGeolocationEnabledNotification)
NOTIFICATION_IMPL(MBLocationServiceDidUpdateLocationNotification)
NOTIFICATION_IMPL(MBLocationServiceLocation)

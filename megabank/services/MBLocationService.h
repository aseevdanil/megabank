//
//  MBLocationService.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>



@interface MBLocationService : NSObject <MBService>
{
	CLLocationManager *_locationManager;
	CLLocation *_location;
	unsigned int _launched : 1;
}

SINGLETON_DECL(sharedService)

@property (nonatomic, copy, readonly) CLLocation *location;

+ (BOOL)isGeolocationAvailable:(NSError**)perror;
+ (BOOL)isGeolocationEnabled:(NSError**)perror;

@end


NOTIFICATION_DECL(MBLocationServiceDidChangeGeolocationEnabledNotification)
NOTIFICATION_DECL(MBLocationServiceDidUpdateLocationNotification)
NOTIFICATION_DECL(MBLocationServiceLocation)

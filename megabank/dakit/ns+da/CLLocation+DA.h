//
//  CLLocation+DA.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>



FOUNDATION_STATIC_INLINE BOOL CLLocationCoordinate2DEqualToLocationCoordinate2D(CLLocationCoordinate2D coordinate1, CLLocationCoordinate2D coordinate2)
{
	return coordinate1.latitude == coordinate2.latitude && coordinate1.longitude == coordinate2.longitude;
}

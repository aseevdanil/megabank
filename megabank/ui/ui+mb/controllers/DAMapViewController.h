//
//  DAMapViewController.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "DAViewController.h"



@interface DAMapViewController : DAViewController <MKMapViewDelegate>
{
	MKMapView *_mapView;
	unsigned int _mapViewReady : 1;
	unsigned int _disabledMapLongPress : 1;
}

@property (nonatomic, strong, readonly) MKMapView *mapView;
- (BOOL)isMapViewReady;
- (void)mapViewDidReady;

@property (nonatomic, assign, getter = isDisabledMapLongPress) BOOL disabledMapLongPress;

@end

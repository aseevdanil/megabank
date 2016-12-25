//
//  MBRegionViewController.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBRegionViewController : MBMapViewController

@property (nonatomic, assign) CLLocationCoordinate2D regionCenterCoordinate;
- (void)didUpdateRegionRadius:(CLLocationDistance)regionRadius;		// Overload

@property (nonatomic, assign) CGFloat conglomerateRadiusInPixels;
- (void)didUpdateConglomerateRadius:(CGFloat)conglomerateRadius;	// Overload

- (void)mapView:(MKMapView * _Nonnull)mapView regionWillChangeAnimated:(BOOL)animated;
- (void)mapView:(MKMapView * _Nonnull)mapView regionDidChangeAnimated:(BOOL)animated;

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@end

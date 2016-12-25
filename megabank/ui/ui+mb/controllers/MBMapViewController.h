//
//  MBMapViewController.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBMapViewController : DAMapViewController <MBViewController>

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views;

@end


@interface MKMapView (MBMapViewController)

- (void)removeAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated;
- (void)removeAnnotations:(NSArray<id<MKAnnotation>>*)annotations animated:(BOOL)animated;

@end

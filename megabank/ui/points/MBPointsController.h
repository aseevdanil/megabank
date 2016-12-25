//
//  MBPointsController.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPoints.h"



@protocol MBPointsControllerChangeObserver;
@class MBPointsAnnotation;


@interface MBPointsController : NSObject
{
	NSFetchRequest *_pointsRequest;
	id<MBPointsControllerChangeObserver> __weak _changeObserver;
	CLLocationCoordinate2D _locationCenter;
	double _conglomerateRadius;
}

- (instancetype)initWithPointsRequest:(NSFetchRequest*)pointsRequest;
@property (nonatomic, strong, readonly) NSFetchRequest *pointsRequest;

@property (nonatomic, assign) CLLocationCoordinate2D locationCenter;	// whan set new locationCenter, conglomerateRadius set to -1.
@property (nonatomic, assign) double conglomerateRadius;	// in map points, если conglomerateRadius == -1. - pointsAnnotations не вычисляются

@property (nonatomic, copy, readonly) NSArray<id<MBPointsAnnotation>> *pointsAnnotations;
@property (nonatomic, weak) id<MBPointsControllerChangeObserver> changeObserver;

@end


@protocol MBPointsControllerChangeObserver
- (void)pointsController:(MBPointsController*)pointsController didChangePointsAnnotations:(NSArray<id<MBPointsAnnotation>>*)updatedPointsAnnotations :(NSArray<id<MBPointsAnnotation>>*)deletedPointsAnnotations :(NSArray<id<MBPointsAnnotation>>*)insertedPointsAnnotations;
@end


//
//  MBPointsModel.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPoints.h"


/*
 Модель отслеживает текущее положение пользователя, при его изменении перезапрашивает точки и перестраивает pointsAnnotations.
 */


@protocol MBPointsModelDelegate;


@interface MBPointsModel : NSObject

- (instancetype)initWithPointsRequest:(NSFetchRequest*)pointsRequest andLoadFunction:(NSString*)pointsLoadFunction;
@property (nonatomic, strong, readonly) NSFetchRequest *pointsRequest;
@property (nonatomic, copy, readonly) NSString *pointsLoadFunction;

@property (nonatomic, assign, readonly, getter = isResumed) BOOL resumed;

@property (nonatomic, assign, readonly) CLLocationCoordinate2D location;
@property (nonatomic, assign) double conglomerateRadius;	// in map points, если conglomerateRadius == -1. - pointsAnnotations не вычисляются
@property (nonatomic, copy, readonly) NSArray<id<MBPointsAnnotation>> *pointsAnnotations;

- (void)loadPointsInRadius:(CLLocationDistance)radius;

@property (nonatomic, weak) id<MBPointsModelDelegate> delegate;

@end


@protocol MBPointsModelDelegate
- (void)pointsModelResumedDidChange:(MBPointsModel*)model;
- (void)pointsModelLocationDidChange:(MBPointsModel*)model;	// need reload all points annotations
- (void)pointsModel:(MBPointsModel*)model didChangePointsAnnotations:(NSArray<id<MBPointsAnnotation>>*)updatedPointsAnnotations :(NSArray<id<MBPointsAnnotation>>*)deletedPointsAnnotations :(NSArray<id<MBPointsAnnotation>>*)insertedPointsAnnotations;
@end

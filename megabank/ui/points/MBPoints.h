//
//  MBPoints.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@protocol MBPoint
@property (nonatomic, assign, readonly) CLLocationCoordinate2D location;
@end


@interface MBMPoint (MBPoint) <MBPoint>

@end



@protocol MBPointsAnnotation <MKAnnotation>
@property (nonatomic, copy, readonly) NSArray<id<MBPoint>> *points;
@end

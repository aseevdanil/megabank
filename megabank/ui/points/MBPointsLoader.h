//
//  MBPointsLoader.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBPointsLoader : NSObject
{
	NSString *_function;
	CLLocationCoordinate2D _locationCoordinate;
	CLLocationDistance _locationRadius;
	id<MBConnectOperation> _connection;
	unsigned int _locationLoaded : 1;
}

- (instancetype)initWithLoadFunction:(NSString*)function;
@property (nonatomic, copy, readonly) NSString *function;

- (void)loadInLocation:(CLLocationCoordinate2D)locationCoordinate radius:(CLLocationDistance)locationRadius;

@end

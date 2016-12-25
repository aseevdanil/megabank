//
//  MBUserInterface.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//


typedef NS_ENUM(NSUInteger, MBSceneIdentifier)
{
	MBSceneNone,
	MBScenePoints,
};


@protocol MBSceneViewController <MBContextReceiver>
@property (nonatomic, assign) MBSceneIdentifier sceneIdentifier;
@end



@interface NSURL (MBImage)

+ (NSURL*)MBImageURLFromImageUrlString:(NSString*)imageUrlString;

@end



@interface UITraitCollection (MBMetric)

@property (nonatomic, assign, readonly) MBMetric metric;

@end

//
//  MBPointsView.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBPointsView : MBAnnotationView
{
	UIImageView *_baseView;
	MBConglomerateView *_conglomerateView;
}

+ (NSString*)identifier;

- (void)setPointURL:(NSURL*)pointURL;
- (void)setPointsURLs:(NSArray<NSURL*>*)pointsURLs withPlaceholder:(NSString*)placeholder;

- (CGRect)pointsAreaFrame;
+ (CGSize)preferredViewSizeForMetric:(MBMetric)metric;

@end



@interface MBPointsView (MBMPoint)

- (void)setMBMPoints:(NSArray<MBMPoint*>*)points;

@end

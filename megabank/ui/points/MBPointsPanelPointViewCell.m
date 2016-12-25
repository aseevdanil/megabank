//
//  MBPointsPanelPointViewCell.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsPanelPointViewCell.h"



@interface MBPointsPanelPointViewCell ()
{
	MBImageView *_pointView;
}

@end


@implementation MBPointsPanelPointViewCell


+ (NSString*)identifier
{
	return @"Point";
}


- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		_pointView = [[MBImageView alloc] initWithFrame:self.contentView.bounds imageForm:MBImageFormCardSlice andEffect:MBImageEffectShapeEllipse];
		_pointView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_pointView.adjustsWhenHighlighted = YES;
		[self.contentView addSubview:_pointView];
	}
	return self;
}


- (void)setPointURL:(NSURL*)pointURL
{
	[_pointView setLoadableImageURL:pointURL];
}


+ (CGSize)itemSizeForMetric:(MBMetric)metric
{
	return [MBImageView preferredViewSizeForMetric:metric withImageForm:MBImageFormCardSlice];
}


+ (CGSize)itemsSpacingForMetric:(MBMetric)metric
{
	static const CGSize Spacing[] =
	{
		/*MBMetricCompact*/	(CGSize){10., 10.},
		/*MBMetricRegular*/ (CGSize){14., 14.},
	};
	return Spacing[metric];
}


@end

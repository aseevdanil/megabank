//
//  MBImage.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBImage.h"



#pragma mark MBImageMetric


@implementation UIImage (MBImageMetric)


- (UIImage*)metricedImage:(MBImageMetric)metric
{
	return [self resizedImage:MBImageMetricSize(metric) resizeScale:metric.resizeScale cropped:metric.cropped];
}


@end



#pragma mark MBImageEffect


@implementation UIImage (MBImageEffect)


- (UIImage*)effectedImage:(MBImageEffect)effect
{
	UIImage *result = self;
	if ((effect & MBImageEffectSegments) != 0)
	{
		if (IS_FLAG(effect, MBImageEffectSegmentHalfR))
		{
			result = [result resizedImage:CGSizeMake(result.size.width / 2, result.size.height) resizeScale:UIImageResizeScaleAspectFill cropped:YES];
			result = [result segmentedImage:UIImageSegmentLeft];
		}
		else if (IS_FLAG(effect, MBImageEffectSegmentHalfT))
		{
			result = [result resizedImage:CGSizeMake(result.size.width, result.size.height / 2) resizeScale:UIImageResizeScaleAspectFill cropped:YES];
			result = [result segmentedImage:UIImageSegmentBottom];
		}
		else if (IS_FLAG(effect, MBImageEffectSegmentHalfL))
		{
			result = [result resizedImage:CGSizeMake(result.size.width / 2, result.size.height) resizeScale:UIImageResizeScaleAspectFill cropped:YES];
			result = [result segmentedImage:UIImageSegmentRight];
		}
		else if (IS_FLAG(effect, MBImageEffectSegmentHalfB))
		{
			result = [result resizedImage:CGSizeMake(result.size.width, result.size.height / 2) resizeScale:UIImageResizeScaleAspectFill cropped:YES];
			result = [result segmentedImage:UIImageSegmentTop];
		}
		else if (IS_FLAG(effect, MBImageEffectSegmentQuarterTR))
		{
			result = [result resizedImage:CGSizeMake(result.size.width / 2, result.size.height / 2) resizeScale:UIImageResizeScaleAspectFill cropped:YES];
			result = [result segmentedImage:UIImageSegmentBottomLeft];
		}
		else if (IS_FLAG(effect, MBImageEffectSegmentQuarterTL))
		{
			result = [result resizedImage:CGSizeMake(result.size.width / 2, result.size.height / 2) resizeScale:UIImageResizeScaleAspectFill cropped:YES];
			result = [result segmentedImage:UIImageSegmentBottomRight];
		}
		else if (IS_FLAG(effect, MBImageEffectSegmentQuarterBL))
		{
			result = [result resizedImage:CGSizeMake(result.size.width / 2, result.size.height / 2) resizeScale:UIImageResizeScaleAspectFill cropped:YES];
			result = [result segmentedImage:UIImageSegmentTopRight];
		}
		else if (IS_FLAG(effect, MBImageEffectSegmentQuarterBR))
		{
			result = [result resizedImage:CGSizeMake(result.size.width / 2, result.size.height / 2) resizeScale:UIImageResizeScaleAspectFill cropped:YES];
			result = [result segmentedImage:UIImageSegmentTopLeft];
		}
	}
	if ((effect & MBImageEffectShapes) != 0)
	{
		result = [result shapedImage:MBImageEffectImageShape(effect)];
	}
	return result;
}


@end

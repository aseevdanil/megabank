//
//  MBUserInterface.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBUserInterface.h"



@implementation NSURL (MBImage)


+ (NSURL*)MBImageURLFromImageUrlString:(NSString*)imageUrlString
{
	static NSString *const MBImagesUrlFormat = @"https://static.tinkoff.ru/icons/deposition-partners-v3/%@/%@";
	return imageUrlString ? [NSURL URLWithString:[NSString stringWithFormat:MBImagesUrlFormat, UIScreenScale() > 1. ? @"xxhdpi" : @"hdpi", imageUrlString]] : nil;
}


@end



@implementation UITraitCollection (MBMetric)


- (MBMetric)metric
{
	return self.horizontalSizeClass == UIUserInterfaceSizeClassRegular ? MBMetricRegular : MBMetricCompact;
}


@end

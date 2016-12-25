//
//  UIColor+MB.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "UIColor+MB.h"



@implementation UIColor (MB)


+ (UIColor*)MBBackgroundColor
{
	return [UIColor whiteColor];
}


+ (UIColor*)MBTintColor
{
	return [UIColor colorWithRed:150. / 255. green:185. / 255. blue:213. / 255. alpha:1.];
}


+ (UIColor*)MBMainTextColor
{
	return [UIColor darkTextColor];
}


+ (UIColor*)MBHelperColor
{
	return [UIColor grayColor];
}


@end

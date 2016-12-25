//
//  UIFont+MB.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "UIFont+MB.h"



@implementation UIFont (MB)


+ (UIFont*)MBLabelFontWithTraitCollection:(UITraitCollection *)traitCollection
{
	return [self preferredFontForTextStyle:UIFontTextStyleCaption2 compatibleWithTraitCollection:traitCollection];
}


@end

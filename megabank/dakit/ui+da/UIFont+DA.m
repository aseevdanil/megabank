//
//  UIFont+DA.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "UIFont+DA.h"



@implementation UIFont (DA)


- (CGFloat)lineScreenHeight
{
	return SCREEN_LENGTH(self.lineHeight, YES);
}


@end

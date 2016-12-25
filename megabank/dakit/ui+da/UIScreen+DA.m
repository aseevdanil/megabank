//
//  UIScreen+DA.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "UIScreen+DA.h"

#import <UIKit/UIKit.h>



inline CGFloat UIScreenScale()
{
	static CGFloat ScreenScale = 1.;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{ ScreenScale = [UIScreen mainScreen].scale; });
	return ScreenScale;
}


inline CGFloat UIScreenPixel()
{
	static CGFloat ScreenPixel = 1.;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{ ScreenPixel = 1. / UIScreenScale(); });
	return ScreenPixel;
}


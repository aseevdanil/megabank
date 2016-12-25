//
//  UIImage+MB.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "UIImage+MB.h"



@implementation UIImage (MB)


#pragma mark Pin

#define R 1.
#define P .8

CGSize CGPathGetPinSize(CGFloat pinRadius)
{
	CGFloat ratio = (2 * R) / (2 * R + P);
	CGFloat width = 2 * pinRadius;
	CGFloat height = width / ratio;
	return CGSizeMake(width, height);
}

CGPathRef CGPathCreateWithPinInRect(CGRect rect, const CGAffineTransform * __nullable transform)
{
	CGFloat radius = rect.size.width / 2;
	CGPoint center = rect.origin;
	center.x += radius;
	center.y += (rect.size.height - rect.size.width) + radius;
	CGAffineTransform pathTransform = CGAffineTransformMake(rect.size.width / (2 * R), 0., 0., rect.size.height / (2 * R + P), center.x, center.y);
	if (transform)
		pathTransform = CGAffineTransformConcat(pathTransform, *transform);
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, &pathTransform, 0., -(R + P));
	CGPathAddCurveToPoint(path, &pathTransform, R / 15., -(R + P), R, -P, R, 0.);
	CGPathAddArc(path, &pathTransform, 0., 0., R, 0., M_PI, false);
	CGPathAddCurveToPoint(path, &pathTransform, -R, -P, -R / 15., -(R + P), 0., -(R + P));
	CGPathCloseSubpath(path);
	return path;
}

#undef P
#undef R

void CGContextAddPinInRect(CGContextRef __nullable c, CGRect rect)
{
	CGPathRef pinPath = CGPathCreateWithPinInRect(rect, NULL);
	CGContextAddPath(c, pinPath);
	CGPathRelease(pinPath);
}

CGImageRef CGImageCreatePinImage(CGFloat pinRadius, CGColorRef pinColor)
{
	CGSize pinSize = CGPathGetPinSize(pinRadius);
	pinSize = CGSizeIntegral(pinSize);
	
	CGColorSpaceRef space = NULL;
	CGContextRef context = NULL;
	CGImageRef image = NULL;
	
	space = CGColorSpaceCreateDeviceRGB();
	if (!space)
		goto cleanup;
	
	context = CGBitmapContextCreate(NULL, pinSize.width, pinSize.height, 8, 0, space, kCGImageAlphaPremultipliedLast);
	if (!context)
		goto cleanup;
	
	CGRect rect = (CGRect){.origin = CGPointZero, .size = pinSize};
	CGContextAddPinInRect(context, rect);
	CGContextSetFillColorWithColor(context, pinColor);
	CGContextFillPath(context);
	
	image = CGBitmapContextCreateImage(context);
	
cleanup:
	if (context)
		CGContextRelease(context);
	if (space)
		CGColorSpaceRelease(space);
	
	return image;
}


+ (UIImage*)pinImage:(CGFloat)pinRadius color:(UIColor*)pinColor
{
	if (!pinColor)
		pinColor = [UIColor blackColor];
	UIImage *image = nil;
	CGImageRef cgimage = CGImageCreatePinImage(pinRadius * UIScreenScale(), pinColor.CGColor);
	if (cgimage)
	{
		image = [UIImage imageWithCGImage:cgimage scale:UIScreenScale() orientation:UIImageOrientationUp];
		CGImageRelease(cgimage);
	}
	return image;
}


+ (CGSize)pinImageSize:(CGFloat)pinRadius
{
	return CGPathGetPinSize(pinRadius);
}


@end

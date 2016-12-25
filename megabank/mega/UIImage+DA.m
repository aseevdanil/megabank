//
//  UIImage+DA.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "UIImage+DA.h"



@implementation UIImage (DA)


- (UIImage*)shapedImage:(UIImageShape)shape
{
	if (shape == UIImageShapeRectangle)
		return self;
	
	CGSize imageSize = self.size;
	CGFloat imageScale = self.scale;
	UIImageOrientation imageOrientation = self.imageOrientation;
	
	CGSize bitmapSize = imageSize;
	bitmapSize.width *= imageScale;
	bitmapSize.height *= imageScale;
	bitmapSize = CGSizeIntegral(bitmapSize);
	
	BOOL transposed = NO;
	switch (imageOrientation)
	{
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transposed = YES;
			break;
		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
		default:
			break;
	}
	if (transposed)
	{
		CGFloat t = bitmapSize.width;
		bitmapSize.width = bitmapSize.height;
		bitmapSize.height = t;
	}
	
	CGImageRef cgimage = self.CGImage;
	if (!cgimage)
		return nil;
	
	CGImageRef result = NULL;
	CGColorSpaceRef space = NULL;
	CGContextRef context = NULL;
	
	space = CGColorSpaceCreateDeviceRGB();
	if (!space)
		goto cleanup;
	
	context = CGBitmapContextCreate(NULL, bitmapSize.width, bitmapSize.height, 8, 0, space, kCGImageAlphaPremultipliedLast);
	if (!context)
		goto cleanup;
	
	CGContextSetShouldAntialias(context, true);
	CGRect rect = CGRectMake(.0, .0, bitmapSize.width, bitmapSize.height);
	CGContextAddImageShapeInRect(context, shape, rect);
	CGContextClip(context);
	CGContextDrawImage(context, rect, cgimage);
	
	result = CGBitmapContextCreateImage(context);
	
cleanup:
	if (context)
		CGContextRelease(context);
	if (space)
		CGColorSpaceRelease(space);
	
	UIImage *image = nil;
	if (result)
	{
		image = [UIImage imageWithCGImage:result scale:imageScale orientation:imageOrientation];
		CGImageRelease(result);
	}
	return image;
}


- (UIImage*)segmentedImage:(UIImageSegment)segment
{
	CGSize bitmapSize = CGSizeIntegral(CGSizeMultiply(self.size, self.scale));
	CGRect ellipseRect = (CGRect){.origin = CGPointZero, .size = bitmapSize};
	switch (segment)
	{
		case UIImageSegmentRight:
			ellipseRect.size.width += ellipseRect.size.width;
			break;
		case UIImageSegmentTop:
			ellipseRect.size.height += ellipseRect.size.height;
			break;
		case UIImageSegmentLeft:
			ellipseRect.origin.x -= ellipseRect.size.width;
			ellipseRect.size.width += ellipseRect.size.width;
			break;
		case UIImageSegmentBottom:
			ellipseRect.origin.y -= ellipseRect.size.height;
			ellipseRect.size.height += ellipseRect.size.height;
			break;
		case UIImageSegmentTopRight:
			ellipseRect.size.width += ellipseRect.size.width;
			ellipseRect.size.height += ellipseRect.size.height;
			break;
		case UIImageSegmentTopLeft:
			ellipseRect.origin.x -= ellipseRect.size.width;
			ellipseRect.size.width += ellipseRect.size.width;
			ellipseRect.size.height += ellipseRect.size.height;
			break;
		case UIImageSegmentBottomLeft:
			ellipseRect.origin.x -= ellipseRect.size.width;
			ellipseRect.size.width += ellipseRect.size.width;
			ellipseRect.origin.y -= ellipseRect.size.height;
			ellipseRect.size.height += ellipseRect.size.height;
			break;
		case UIImageSegmentBottomRight:
			ellipseRect.size.width += ellipseRect.size.width;
			ellipseRect.origin.y -= ellipseRect.size.height;
			ellipseRect.size.height += ellipseRect.size.height;
			break;
		case UIImageSegmentNone:
		default:
			break;
	}
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	BOOL transposed = NO;
	switch (self.imageOrientation)
	{
		case UIImageOrientationDown:
			transform = CGAffineTransformRotate(transform, -M_PI);
			transform = CGAffineTransformTranslate(transform, -bitmapSize.width, -bitmapSize.height);
			break;
		case UIImageOrientationLeft:
			transform = CGAffineTransformRotate(transform, M_PI_2);
			transform = CGAffineTransformTranslate(transform, 0., -bitmapSize.height);
			transposed = YES;
			break;
		case UIImageOrientationRight:
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			transform = CGAffineTransformTranslate(transform, -bitmapSize.width, 0.);
			transposed = YES;
			break;
		case UIImageOrientationUpMirrored:
			transform = CGAffineTransformScale(transform, -1, 0);
			transform = CGAffineTransformTranslate(transform, -bitmapSize.width, 0.);
			break;
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformRotate(transform, -M_PI);
			transform = CGAffineTransformTranslate(transform, 0., -bitmapSize.height);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformRotate(transform, M_PI_2);
			transform = CGAffineTransformTranslate(transform, -bitmapSize.width, -bitmapSize.height);
			transform = CGAffineTransformScale(transform, -1, 1);
			transposed = YES;
			break;
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			transform = CGAffineTransformScale(transform, -1, 1);
			transposed = YES;
			break;
		case UIImageOrientationUp:
		default:
			break;
	}
	ellipseRect = CGRectApplyAffineTransform(ellipseRect, transform);
	if (transposed)
	{
		CGFloat t = bitmapSize.width;
		bitmapSize.width = bitmapSize.height;
		bitmapSize.height = t;
	}
	
	CGImageRef cgimage = self.CGImage;
	if (!cgimage)
		return nil;
	
	CGImageRef result = NULL;
	CGColorSpaceRef space = NULL;
	CGContextRef context = NULL;
	
	space = CGColorSpaceCreateDeviceRGB();
	if (!space)
		goto cleanup;
	
	context = CGBitmapContextCreate(NULL, bitmapSize.width, bitmapSize.height, 8, 0, space, kCGImageAlphaPremultipliedLast);
	if (!context)
		goto cleanup;
	
	CGContextSetShouldAntialias(context, true);
	CGContextAddEllipseInRect(context, ellipseRect);
	CGContextClip(context);
	CGRect imageRect = (CGRect){.origin = CGPointZero, .size = bitmapSize};
	CGContextDrawImage(context, imageRect, cgimage);
	
	result = CGBitmapContextCreateImage(context);
	
cleanup:
	if (context)
		CGContextRelease(context);
	if (space)
		CGColorSpaceRelease(space);
	
	UIImage *segmentedImage = nil;
	if (result)
	{
		segmentedImage = [UIImage imageWithCGImage:result scale:self.scale orientation:self.imageOrientation];
		CGImageRelease(result);
	}
	return segmentedImage;
}


#pragma mark -


- (UIImage*)standardOrientedImage
{
	static const struct
	{
		UIImageRotation rotation;
		BOOL mirrored;
	}
	OrientationToRotation[] =
	{
		/*UIImageOrientationUp*/			UIImageRotationNone, NO,
		/*UIImageOrientationDown*/			UIImageRotationDown, NO,
		/*UIImageOrientationLeft*/			UIImageRotationLeft, NO,
		/*UIImageOrientationRight*/			UIImageRotationRight, NO,
		/*UIImageOrientationUpMirrored*/	UIImageRotationNone, YES,
		/*UIImageOrientationDownMirrored*/	UIImageRotationDown, YES,
		/*UIImageOrientationLeftMirrored*/	UIImageRotationLeft, YES,
		/*UIImageOrientationRightMirrored*/	UIImageRotationRight, YES,
	};
	UIImageOrientation imageOrientation = self.imageOrientation;
	if (OrientationToRotation[imageOrientation].rotation == UIImageRotationNone && !OrientationToRotation[imageOrientation].mirrored)
		return self;
	UIImage *rotatedImage = [self rotatedImage:OrientationToRotation[imageOrientation].rotation mirrored:OrientationToRotation[imageOrientation].mirrored];
	return [UIImage imageWithCGImage:rotatedImage.CGImage scale:self.scale orientation:UIImageOrientationUp];
}


- (UIImage*)filledImage:(UIColor*)filledColor
{
	UIImage *image = nil;
	if (!filledColor)
		filledColor = [UIColor whiteColor];
	CGImageRef imageRef = CGImageCreateFilledImage(self.CGImage, filledColor.CGColor);
	if (imageRef)
	{
		image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
		CGImageRelease(imageRef);
	}
	return image;
}


@end



CG_EXTERN CGPathRef CGPathCreateWithImageShapeInRect(UIImageShape shape, CGRect rect, const CGAffineTransform *transform)
{
	switch (shape)
	{
		case UIImageShapeEllipse:	return CGPathCreateWithEllipseInRect(rect, transform);
		case UIImageShapeRectangle:
		default:					return CGPathCreateWithRect(rect, transform);
	}
}


CG_EXTERN void CGContextAddImageShapeInRect(CGContextRef __nullable c, UIImageShape shape, CGRect rect)
{
	switch (shape)
	{
		case UIImageShapeEllipse:	return CGContextAddEllipseInRect(c, rect);
		case UIImageShapeRectangle:
		default:					return CGContextAddRect(c, rect);
	}
}


CG_EXTERN CGImageRef CGImageCreateFilledImageShape(UIImageShape shape, CGSize size, CGColorRef fillColor)
{
	DASSERT(fillColor);
	
	size = CGSizeIntegral(size);
	
	CGImageRef image = NULL;
	CGContextRef context = NULL;
	CGColorSpaceRef space = NULL;
	
	space = CGColorSpaceCreateDeviceRGB();
	if (!space)
		goto cleanup;
	
	context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, space, kCGImageAlphaPremultipliedLast);
	if (!context)
		goto cleanup;
	
	CGRect rect = (CGRect){.origin = CGPointZero, .size = size};
	CGContextAddImageShapeInRect(context, shape, rect);
	CGContextSetFillColorWithColor(context, fillColor);
	CGContextDrawPath(context, kCGPathFill);
	
	image = CGBitmapContextCreateImage(context);
	
cleanup:
	if (context)
		CGContextRelease(context);
	if (space)
		CGColorSpaceRelease(space);
	
	return image;
}


CG_EXTERN CGImageRef CGImageCreateStrokeImageShape(UIImageShape shape, CGSize size, CGFloat strokeWidth, CGColorRef strokeColor)
{
	DASSERT(strokeColor);
	
	size = CGSizeIntegral(size);
	strokeWidth = (CGFloat)(NSInteger) strokeWidth;
	
	CGImageRef image = NULL;
	CGContextRef context = NULL;
	CGColorSpaceRef space = NULL;
	
	space = CGColorSpaceCreateDeviceRGB();
	if (!space)
		goto cleanup;
	
	context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, space, kCGImageAlphaPremultipliedLast);
	if (!context)
		goto cleanup;
	
	CGRect rect = (CGRect){.origin = CGPointZero, .size = size};
	rect = CGRectInset(rect, strokeWidth / 2, strokeWidth / 2);
	CGContextAddImageShapeInRect(context, shape, rect);
	CGContextSetLineWidth(context, strokeWidth);
	CGContextSetStrokeColorWithColor(context, strokeColor);
	CGContextDrawPath(context, kCGPathStroke);
	
	image = CGBitmapContextCreateImage(context);
	
cleanup:
	if (context)
		CGContextRelease(context);
	if (space)
		CGColorSpaceRelease(space);
	
	return image;
}

//
//  MBMapButton.m
//  megabank
//
//  Created by da on 04.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBMapButton.h"



static CGImageRef CGImageCreateButtonImage(MBMapButtonType type, CGSize size, CGFloat lineWidth, CGColorRef color)
{
	CGImageRef image = NULL;
	CGColorSpaceRef space = NULL;
	CGContextRef context = NULL;
	
	size = CGSizeIntegral(size);
	lineWidth = (CGFloat)(NSInteger) lineWidth;
	
	space = CGColorSpaceCreateDeviceRGB();
	if (!space)
		goto cleanup;
	
	context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, space, (CGBitmapInfo) kCGImageAlphaPremultipliedLast);
	if (!context)
		goto cleanup;
	
	CGRect rect = (CGRect){.origin = CGPointZero, .size = size};
	CGContextSetFillColorWithColor(context, color);
	CGContextFillEllipseInRect(context, rect);
	rect = CGRectInset(rect, rect.size.width / 3, rect.size.height / 3);
	switch (type)
	{
		case MBMapButtonTypeScaleUp:
			CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect));
			CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
		case MBMapButtonTypeScaleDown:
			CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
			CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
			break;
		case MBMapButtonTypeUnk:
		default:
			break;
	}
	CGContextSetLineWidth(context, lineWidth);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetBlendMode(context, kCGBlendModeClear);
	CGContextDrawPath(context, kCGPathStroke);
	
	image = CGBitmapContextCreateImage(context);
	
cleanup:
	if (context)
		CGContextRelease(context);
	if (space)
		CGColorSpaceRelease(space);
	
	return image;
}



@interface MBMapButton ()
{
	MBMapButtonType _type;
}

@end


@implementation MBMapButton


@synthesize type = _type;


- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame type:MBMapButtonTypeUnk];
}


- (instancetype)initWithType:(MBMapButtonType)type
{
	return [self initWithFrame:CGRectZero type:type];
}


- (instancetype)initWithFrame:(CGRect)frame type:(MBMapButtonType)type
{
	if ((self = [super initWithFrame:frame]))
	{
		_type = type;
		self.showsTouchWhenHighlighted = NO;
		self.adjustsImageWhenHighlighted = NO;
		self.adjustsImageWhenDisabled = NO;
	}
	return self;
}


+ (UIImage*)buttonImage:(MBMapButtonType)type transparent:(BOOL)transparent metric:(MBMetric)metric
{
	if (type == MBMapButtonTypeUnk)
		return nil;
	static UIImage *Images[MBMapButtonTypeCount - 1][MBMetricCount][2] = { 0 };	// см. комментарий [MBPointsView pinImageForMetric:]
	UIImage *image = Images[type - 1][metric][transparent ? 1 : 0];
	if (!image)
	{
		UIColor *color = [UIColor MBHelperColor];
		if (transparent)
			color = [color colorWithAlphaComponent:.5];
		CGImageRef imageRef = CGImageCreateButtonImage(type, CGSizeMultiply([self buttonImageSize:metric], UIScreenScale()), 2. * UIScreenScale(),color.CGColor);
		if (imageRef)
		{
			image = [UIImage imageWithCGImage:imageRef scale:UIScreenScale() orientation:UIImageOrientationUp];
			CGImageRelease(imageRef);
			//image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
			Images[type - 1][metric][transparent ? 1 : 0] = image;
		}
	}
	return image;
}


+ (CGSize)buttonImageSize:(MBMetric)metric
{
	static const CGSize Size[] =
	{
		/*MBMetricCompact*/	(CGSize){33., 33.},
		/*MBMetricRegular*/ (CGSize){44., 44.},
	};
	return Size[metric];
}


- (void)updateMetric
{
	[super updateMetric];
	UIImage *normalImage = [MBMapButton buttonImage:_type transparent:NO metric:self.metric], *transpImage = [MBMapButton buttonImage:_type transparent:YES metric:self.metric];
	[self setImage:normalImage forState:UIControlStateNormal];
	[self setImage:transpImage forState:UIControlStateNormal | UIControlStateHighlighted];
	[self setImage:transpImage forState:UIControlStateNormal | UIControlStateDisabled];
	self.bounds = (CGRect){.origin = CGPointZero, .size = [MBMapButton preferredButtonSizeForMetric:self.metric]};
}


- (CGSize)sizeThatFits:(CGSize)size
{
	CGSize prefferedSize = [MBMapButton preferredButtonSizeForMetric:self.metric];
	if (size.width > prefferedSize.width)
		size.width = prefferedSize.width;
	if (size.height == 0. || size.height > prefferedSize.height)
		size.height = prefferedSize.height;
	return size;
}


+ (CGSize)preferredButtonSizeForMetric:(MBMetric)metric
{
	return [MBMapButton buttonImageSize:metric];
}


@end



@implementation MBMapButtonItem


@synthesize tag = _tag, target = _target, action = _action;


- (instancetype)initWithTarget:(id)target action:(SEL)action
{
	if ((self = [super init]))
	{
		_tag = 0;
		_target = target;
		_action = action;
		_hidden = NO;
		_enabled = YES;
	}
	return self;
}


- (BOOL)isHidden
{
	return _hidden;
}


- (void)setHidden:(BOOL)hidden
{
	_hidden = hidden;
}


- (BOOL)isEnabled
{
	return _enabled;
}


- (void)setEnabled:(BOOL)enabled
{
	_enabled = enabled;
}


@end

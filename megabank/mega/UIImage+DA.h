//
//  UIImage+DA.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



typedef NS_ENUM(NSUInteger, UIImageShape)
{
	UIImageShapeRectangle,
	UIImageShapeEllipse,
};


typedef NS_ENUM(NSUInteger, UIImageSegment)
{
	UIImageSegmentNone,
	UIImageSegmentRight,
	UIImageSegmentTop,
	UIImageSegmentLeft,
	UIImageSegmentBottom,
	UIImageSegmentTopRight,
	UIImageSegmentTopLeft,
	UIImageSegmentBottomLeft,
	UIImageSegmentBottomRight,
};


@interface UIImage (DA)

- (UIImage*)shapedImage:(UIImageShape)shape;
- (UIImage*)segmentedImage:(UIImageSegment)segment;

- (UIImage*)standardOrientedImage;
- (UIImage*)filledImage:(UIColor*)filledColor;

@end



CG_EXTERN CGPathRef CGPathCreateWithImageShapeInRect(UIImageShape shape, CGRect rect, const CGAffineTransform *transform);
CG_EXTERN void CGContextAddImageShapeInRect(CGContextRef c, UIImageShape shape, CGRect rect);
CG_EXTERN CGImageRef CGImageCreateFilledImageShape(UIImageShape shape, CGSize size, CGColorRef fillColor);
CG_EXTERN CGImageRef CGImageCreateStrokeImageShape(UIImageShape shape, CGSize size, CGFloat strokeWidth, CGColorRef strokeColor);

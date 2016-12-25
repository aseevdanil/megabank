//
//  MBImage.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//


#pragma mark MBUserInterfaceMetric


typedef NS_ENUM(NSUInteger, MBMetric)
{
	MBMetricCompact,
	MBMetricRegular,
	
	MBMetricCount,
};


NS_INLINE NSString *const MBMetricDescription(MBMetric size)
{
	static NSString *const Descriptions[] =
	{
		/*MBMetricCompact*/	@"compact",
		/*MBMetricRegular*/	@"regular",
	};
	return Descriptions[size];
}



#pragma mark MBImageMetric


struct MBImageMetric
{
	u_int16_t width, height;
	u_int8_t scale;
	UIImageResizeScale resizeScale : 2;
	BOOL cropped : 1;
};
typedef struct MBImageMetric MBImageMetric;


static const MBImageMetric MBImageMetricNull = (MBImageMetric){0, 0, 0, UIImageResizeScaleFill, NO};


NS_INLINE MBImageMetric MBImageMetricMake(u_int16_t width, u_int16_t height, u_int8_t scale, UIImageResizeScale resizeScale, BOOL cropped)
{
	MBImageMetric metric;
	metric.width = width;
	metric.height = height;
	metric.scale = scale;
	metric.resizeScale = resizeScale;
	metric.cropped = cropped;
	return metric;
}

NS_INLINE BOOL MBImageMetricEqualToMetric(MBImageMetric metric1, MBImageMetric metric2)
{
	return metric1.width == metric2.width && metric1.height == metric2.height && metric1.scale == metric2.scale && metric1.resizeScale == metric2.resizeScale && metric1.cropped == metric2.cropped;
}

NS_INLINE CGSize MBImageMetricSize(MBImageMetric metric)
{
	return CGSizeMake((CGFloat) metric.width / metric.scale, (CGFloat) metric.height / metric.scale);
}


NS_INLINE CGSize UIImageMetricedImageSize(CGSize originalSize, MBImageMetric metric) { return UIImageResizedImageSize(originalSize, MBImageMetricSize(metric), metric.resizeScale, metric.cropped); }


@interface UIImage (MBImageMetric)

- (UIImage*)metricedImage:(MBImageMetric)metric;

@end



#pragma mark MBImageEffect


typedef NS_OPTIONS(NSUInteger, MBImageEffect)
{
	MBImageEffectNone				= 0,
	
	MBImageEffectShapeRect			= 0x00,			// Оставляет прямоугольную картинку
	MBImageEffectShapeEllipse		= 0x01,			// Вырезает из картинки круг соответствующего размера
	MBImageEffectShapes				= 0xFF,
	
	MBImageEffectSegmentHalfR		= 0x01 << 16,
	MBImageEffectSegmentHalfT		= 0x02 << 16,
	MBImageEffectSegmentHalfL		= 0x04 << 16,
	MBImageEffectSegmentHalfB		= 0x08 << 16,
	MBImageEffectSegmentQuarterTR	= 0x10 << 16,
	MBImageEffectSegmentQuarterTL	= 0x20 << 16,
	MBImageEffectSegmentQuarterBL	= 0x40 << 16,
	MBImageEffectSegmentQuarterBR	= 0x80 << 16,
	MBImageEffectSegments			= 0xFF << 16,	// Сегментированная картинка (картинка масштабируется до нужного размера и из нее вырезается полукруг или четверть)
};

NS_INLINE NSString *const MBImageEffectDescription(MBImageEffect effect)
{
	NSString *description = @"";
	if ((effect & MBImageEffectShapes) != 0)
	{
		if (IS_FLAG(effect, MBImageEffectShapeEllipse))
			description = [description stringByAppendingString:@"shapeellipse"];
	}
	if ((effect & MBImageEffectSegments) != 0)
	{
		if (IS_FLAG(effect, MBImageEffectSegmentHalfR))
			description = [description stringByAppendingString:@"segmenthalfr"];
		else if (IS_FLAG(effect, MBImageEffectSegmentHalfT))
			description = [description stringByAppendingString:@"segmenthalft"];
		else if (IS_FLAG(effect, MBImageEffectSegmentHalfL))
			description = [description stringByAppendingString:@"segmenthalfl"];
		else if (IS_FLAG(effect, MBImageEffectSegmentHalfB))
			description = [description stringByAppendingString:@"segmenthalfb"];
		else if (IS_FLAG(effect, MBImageEffectSegmentQuarterTR))
			description = [description stringByAppendingString:@"segmentquartertr"];
		else if (IS_FLAG(effect, MBImageEffectSegmentQuarterTL))
			description = [description stringByAppendingString:@"segmentquartertl"];
		else if (IS_FLAG(effect, MBImageEffectSegmentQuarterBL))
			description = [description stringByAppendingString:@"segmentquarterbl"];
		else if (IS_FLAG(effect, MBImageEffectSegmentQuarterBR))
			description = [description stringByAppendingString:@"segmentquarterbr"];
	}
	return description;
}


NS_INLINE UIImageShape MBImageEffectImageShape(MBImageEffect effect)
{
	if (IS_FLAG(effect, MBImageEffectShapeEllipse))
		return UIImageShapeEllipse;
	else
		return UIImageShapeRectangle;
}


@interface UIImage (MBImageEffect)

- (UIImage*)effectedImage:(MBImageEffect)effect;

@end



#pragma mark MBImageForm


typedef NS_ENUM(NSUInteger, MBImageForm)
{
	MBImageFormCardPict,
	MBImageFormCardSlice,
};


#define METRIC(w, h, s, resize, crop) (MBImageMetric){ w, h, s, resize, crop }
#define FIT			UIImageResizeScaleAspectFit
#define FILL		UIImageResizeScaleAspectFill

/*
 Thumb - миниатюра или тумбнеил в зависимости от size
 Pict - миниатюра (полная картинка без обрезаний)
 Slice - тумбнеил (вырезанный фрагмент из картинки)
 */

static const MBImageMetric MBImageMetricTable[][MBMetricCount] =
{									/*MBMetricCompact*/				/*MBMetricRegular*/
	/*MBImageFormCardPict*/			METRIC(120, 120, 2, FIT, YES),	METRIC(160, 160, 2, FIT, YES),
	/*MBImageFormCardSlice*/		METRIC(120, 120, 2, FILL, YES),	METRIC(160, 160, 2, FILL, YES),
};

#undef FILL
#undef FIT
#undef METRIC


NS_INLINE NSString *const MBImageFormDescription(MBImageForm form)
{
	static NSString *const Descriptions[] =
	{
		/*MBImageFormCardPict*/			@"cardpict",
		/*MBImageFormCardSlice*/		@"cardslice",
	};
	return Descriptions[form];
}

//
//  MBConglomerateView.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBConglomerateView.h"



@implementation MBConglomerateView


@synthesize imageForm = _imageForm;


- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame imageForm:0];
}


- (instancetype)initWithImageForm:(MBImageForm)imageForm
{
	return [self initWithFrame:CGRectZero imageForm:imageForm];
}


- (instancetype)initWithFrame:(CGRect)frame imageForm:(MBImageForm)imageForm
{
	if ((self = [super initWithFrame:frame]))
	{
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = NO;
		_imageForm = imageForm;
		_highlighted = NO;
		_adjustsWhenHighlighted = NO;
		_imagesViews = [[NSMutableArray alloc] initWithCapacity:[MBConglomerateView maximumPresentedImagesWithPlaceholder:NO]];
	}
	return self;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	if (_placeholderLabel)
		_placeholderLabel.font = [UIFont MBLabelFontWithTraitCollection:self.traitCollection];
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect bounds = self.bounds;
	CGRect imagesFrame = bounds;
	imagesFrame.size = [MBImageView preferredViewSizeForMetric:self.metric withImageForm:_imageForm];
	imagesFrame.origin.x += (bounds.size.width - imagesFrame.size.width) / 2;
	imagesFrame.origin.y += (bounds.size.height - imagesFrame.size.height) / 2;
	CGRect imageViewFrame = imagesFrame;
	NSUInteger imagesViewsCount = _imagesViews.count;
	NSUInteger imagesViewsCountWithPlaceholder = imagesViewsCount + (_placeholderLabel ? 1 : 0);
	if (imagesViewsCountWithPlaceholder > 1)
	{
		if (imagesViewsCountWithPlaceholder == 2)
		{
			MBImageView *imageView1 = (MBImageView*)[_imagesViews objectAtIndex:0];
			imageViewFrame.size.width /= 2;
			imageView1.frame = imageViewFrame;
			imageViewFrame.origin.x += imageViewFrame.size.width;
		}
		else if (imagesViewsCountWithPlaceholder == 3)
		{
			MBImageView *imageView1 = (MBImageView*)[_imagesViews objectAtIndex:0];
			MBImageView *imageView2 = (MBImageView*)[_imagesViews objectAtIndex:1];
			imageViewFrame.size.width /= 2;
			imageView1.frame = imageViewFrame;
			imageViewFrame.size.height /= 2;
			imageViewFrame.origin.x += imageViewFrame.size.width;
			imageView2.frame = imageViewFrame;
			imageViewFrame.origin.y += imageViewFrame.size.height;
		}
		else
		{
			MBImageView *imageView1 = (MBImageView*)[_imagesViews objectAtIndex:0];
			MBImageView *imageView2 = (MBImageView*)[_imagesViews objectAtIndex:1];
			MBImageView *imageView3 = (MBImageView*)[_imagesViews objectAtIndex:2];
			imageViewFrame.size.width /= 2;
			imageViewFrame.size.height /= 2;
			imageView1.frame = imageViewFrame;
			imageViewFrame.origin.x += imageViewFrame.size.width;
			imageView2.frame = imageViewFrame;
			imageViewFrame.origin.x -= imageViewFrame.size.width;
			imageViewFrame.origin.y += imageViewFrame.size.height;
			imageView3.frame = imageViewFrame;
			imageViewFrame.origin.x += imageViewFrame.size.width;
		}
	}
	if (_placeholderLabel)
	{
		CGRect placeholderLabelFrame = imageViewFrame;
		placeholderLabelFrame.size.height = _placeholderLabel.font.lineScreenHeight;
		//placeholderLabelFrame.origin.x += (imageViewFrame.size.width - placeholderLabelFrame.size.width) / 2;
		placeholderLabelFrame.origin.y += (imageViewFrame.size.height - placeholderLabelFrame.size.height) / 2;
		_placeholderLabel.frame = placeholderLabelFrame;
	}
	else if (imagesViewsCount > 0)
	{
		MBImageView *imageView = (MBImageView*)[_imagesViews objectAtIndex:imagesViewsCount - 1];
		imageView.frame = imageViewFrame;
	}
}


+ (CGSize)preferredViewSizeForMetric:(MBMetric)metric withImageForm:(MBImageForm)imageForm
{
	return [MBImageView preferredViewSizeForMetric:metric withImageForm:imageForm];
}


- (void)setImagesURLs:(NSArray<NSURL*>*)imagesURLs withPlaceholder:(NSString*)placeholder
{
	NSUInteger currentImagesViewsCount = _imagesViews.count;
	NSUInteger currentImagesViewsCountWithPlaceholder = currentImagesViewsCount + (_placeholderLabel ? 1 : 0);
	NSUInteger newImagesViewsCount = imagesURLs ? MIN(imagesURLs.count, [MBConglomerateView maximumPresentedImagesWithPlaceholder:placeholder != nil]) : 0;
	NSUInteger newImagesViewsCountWithPlaceholder = newImagesViewsCount + (placeholder ? 1 : 0);
	if (placeholder)
	{
		if (!_placeholderLabel)
		{
			_placeholderLabel = [[UILabel alloc] init];
			_placeholderLabel.opaque = NO;
			_placeholderLabel.backgroundColor = [UIColor clearColor];
			_placeholderLabel.font = [UIFont MBLabelFontWithTraitCollection:self.traitCollection];
			_placeholderLabel.textAlignment = NSTextAlignmentCenter;
			_placeholderLabel.numberOfLines = 1;
			_placeholderLabel.textColor = [UIColor MBMainTextColor];
			[self addSubview:_placeholderLabel];
			[self setNeedsLayout];
		}
		_placeholderLabel.text = placeholder;
	}
	else
	{
		if (_placeholderLabel)
		{
			[_placeholderLabel removeFromSuperview];
			_placeholderLabel = nil;
			[self setNeedsLayout];
		}
	}
	if (currentImagesViewsCountWithPlaceholder != newImagesViewsCountWithPlaceholder)
	{
		for (MBImageView *imageView in _imagesViews)
			[imageView removeFromSuperview];
		[_imagesViews removeAllObjects];
		if (newImagesViewsCount == 1)
		{
			MBImageView *imageView = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:_placeholderLabel ? MBImageEffectSegmentHalfL : MBImageEffectShapeEllipse];
			[_imagesViews addObject:imageView];
		}
		else if (newImagesViewsCount == 2)
		{
			MBImageView *imageView1 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:MBImageEffectSegmentHalfL];
			MBImageView *imageView2 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:placeholder ? MBImageEffectSegmentQuarterTR : MBImageEffectSegmentHalfR];
			[_imagesViews addObject:imageView1];
			[_imagesViews addObject:imageView2];
		}
		else if (newImagesViewsCount == 3)
		{
			MBImageView *imageView1 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:_placeholderLabel ? MBImageEffectSegmentQuarterTL : MBImageEffectSegmentHalfL];
			MBImageView *imageView2 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:MBImageEffectSegmentQuarterTR];
			MBImageView *imageView3 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:_placeholderLabel ? MBImageEffectSegmentQuarterBL : MBImageEffectSegmentQuarterBR];
			[_imagesViews addObject:imageView1];
			[_imagesViews addObject:imageView2];
			[_imagesViews addObject:imageView3];
		}
		else if (newImagesViewsCount > 3)
		{
			MBImageView *imageView1 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:MBImageEffectSegmentQuarterTL];
			MBImageView *imageView2 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:MBImageEffectSegmentQuarterTR];
			MBImageView *imageView3 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:MBImageEffectSegmentQuarterBL];
			MBImageView *imageView4 = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:MBImageEffectSegmentQuarterBR];
			[_imagesViews addObject:imageView1];
			[_imagesViews addObject:imageView2];
			[_imagesViews addObject:imageView3];
			[_imagesViews addObject:imageView4];
		}
		for (MBImageView *imageView in _imagesViews)
		{
			imageView.adjustsWhenHighlighted = _adjustsWhenHighlighted;
			imageView.highlighted = _highlighted;
			[self addSubview:imageView];
		}
		[self setNeedsLayout];
	}
	else if (currentImagesViewsCount != newImagesViewsCount)
	{
		DASSERT(currentImagesViewsCount - newImagesViewsCount == 1 || newImagesViewsCount - currentImagesViewsCount == 1);
		if (newImagesViewsCount < currentImagesViewsCount)
		{
			MBImageView *imageView = (MBImageView*)[_imagesViews objectAtIndex:currentImagesViewsCount - 1];
			[imageView removeFromSuperview];
			[_imagesViews removeObjectAtIndex:currentImagesViewsCount - 1];
		}
		else
		{
			MBImageEffect segment = newImagesViewsCount > 2 ? MBImageEffectSegmentQuarterBR  : (newImagesViewsCount == 1 ? MBImageEffectShapeEllipse : MBImageEffectSegmentHalfR);
			MBImageView *imageView = [[MBImageView alloc] initWithImageForm:_imageForm andEffect:segment];
			imageView.adjustsWhenHighlighted = _adjustsWhenHighlighted;
			imageView.highlighted = _highlighted;
			[self addSubview:imageView];
			[_imagesViews addObject:imageView];
		}
	}
	DASSERT(newImagesViewsCount == _imagesViews.count);
	for (NSUInteger i = 0; i < imagesURLs.count; ++i)
	{
		NSURL *imageURL = (NSURL*)[imagesURLs objectAtIndex:i];
		if (imageURL == (id)[NSNull null])
			imageURL = nil;
		MBImageView *imageView = (MBImageView*)[_imagesViews objectAtIndex:i];
		[imageView setLoadableImageURL:imageURL];
	}
}


+ (NSUInteger)maximumPresentedImagesWithPlaceholder:(BOOL)placeholder
{
	return placeholder ? 3 : 4;
}


- (BOOL)isHighlighted
{
	return _highlighted;
}


- (void)setHighlighted:(BOOL)highlighted
{
	_highlighted = highlighted;
	for (MBImageView *imageView in _imagesViews)
		imageView.highlighted = highlighted;
}


- (BOOL)isAdjustsWhenHighlighted
{
	return _adjustsWhenHighlighted;
}


- (void)setAdjustsWhenHighlighted:(BOOL)adjustsWhenHighlighted
{
	_adjustsWhenHighlighted = adjustsWhenHighlighted;
	for (MBImageView *imageView in _imagesViews)
		imageView.adjustsWhenHighlighted = adjustsWhenHighlighted;
}


@end

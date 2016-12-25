//
//  MBImageView.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBImageView.h"



@interface MBImageView ()

- (void)resetLoadableImage;
- (void)startLoadingOperation;
- (void)cancelLoadingOperation;

@end


@implementation MBImageView


#pragma mark Base


@synthesize imageForm = _imageForm, imageEffect = _imageEffect;


- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame imageForm:0 andEffect:MBImageEffectNone];
}


- (instancetype)initWithImageForm:(MBImageForm)imageForm andEffect:(MBImageEffect)imageEffect
{
	return [self initWithFrame:CGRectZero imageForm:imageForm andEffect:imageEffect];
}


- (instancetype)initWithFrame:(CGRect)frame imageForm:(MBImageForm)imageForm andEffect:(MBImageEffect)imageEffect
{
	if ((self = [super initWithFrame:frame]))
	{
		self.contentMode = UIViewContentModeCenter;
		_imageForm = imageForm;
		_imageEffect = imageEffect;
		
		_loadableImageLoading = _loadableImageFailed = NO;
		
		_adjustsWhenHighlighted = NO;
	}
	return self;
}


- (void)dealloc
{
	DASSERT(!_loadingOperation);
	[self cancelLoadingOperation];
}


- (void)didMoveToWindow
{
	[super didMoveToWindow];
	if (_loadableImageURL && _loadableImageLoading)
	{
		if (self.window)
		{
			if (!self.needsUpdateMetric)
				if (!_loadingOperation)
					[self startLoadingOperation];
		}
		else
		{
			[self cancelLoadingOperation];
		}
	}
}


- (CGSize)sizeThatFits:(CGSize)size
{
	return [MBImageView preferredViewSizeForMetric:self.metric withImageForm:_imageForm];
}


- (CGRect)getImageBounds
{
	CGRect bounds = self.layer.bounds;
	CGRect imageBounds = bounds;
	if (_loadableImageURL && self.image)
	{
		imageBounds.size = self.image.size;
		imageBounds.origin.x += (bounds.size.width - imageBounds.size.width) / 2;
		imageBounds.origin.y += (bounds.size.height - imageBounds.size.height) / 2;
	}
	return imageBounds;
}


+ (CGSize)preferredViewSizeForMetric:(MBMetric)metric withImageForm:(MBImageForm)form
{
	return MBImageMetricSize(MBImageMetricTable[form][metric]);
}


- (void)didChangeMetric
{
	[super didChangeMetric];
	if (_loadableImageURL && !_loadableImageFailed)
		[self setLoadableImageURL:_loadableImageURL];
}


- (void)updateMetric
{
	[super updateMetric];
	if (_loadableImageURL && _loadableImageLoading)
	{
		if (self.window)
			if (!_loadingOperation)
				[self startLoadingOperation];
	}
}


- (BOOL)isAdjustsWhenHighlighted
{
	return _adjustsWhenHighlighted;
}


- (void)setAdjustsWhenHighlighted:(BOOL)flag
{
	_adjustsWhenHighlighted = flag;
}


- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	if (_adjustsWhenHighlighted)
		self.alpha = self.isHighlighted ? .7 : 1.;
}


#pragma mark Image


- (void)setImage:(UIImage *)image
{
	[self resetLoadableImage];
	[super setImage:image];
}


- (void)setHighlightedImage:(UIImage *)highlightedImage
{
	[self resetLoadableImage];
	[super setHighlightedImage:highlightedImage];
}


- (BOOL)isLoadableImage
{
	return _loadableImageURL != nil;
}


- (BOOL)isLoadableImageLoading
{
	return _loadableImageLoading;
}


- (BOOL)isLoadableImageFailed
{
	return _loadableImageFailed;
}


- (void)setLoadableImageURL:(NSURL*)imageURL
{
	[self resetLoadableImage];
	[super setImage:nil];	// вообще здесь можно подставить плэйсхолдер - картинку по умолчанию, но пока обойдемся без нее)
	if (!imageURL)
		return;
	
	_loadableImageURL = imageURL;
	[self willChangeValueForKey:@"isLoadableImageLoading"];
	_loadableImageLoading = YES;
	[self didChangeValueForKey:@"isLoadableImageLoading"];
	if (self.window && !self.needsUpdateMetric)
		[self startLoadingOperation];
}


- (void)_completeLoadingOperation:(UIImage*)image error:(NSError*)error
{
	_loadingOperation = nil;
	
	DASSERT(_loadableImageURL);
	if (!_loadableImageURL)
		return;
	
	DASSERT(_loadableImageLoading);
	if (!_loadableImageLoading)
		return;
	
	_loadableImageFailed = image == nil;
	
	[self willChangeValueForKey:@"image"];
	[super setImage:image];
	[self didChangeValueForKey:@"image"];
	
	[self willChangeValueForKey:@"isLoadableImageLoading"];
	_loadableImageLoading = NO;
	[self didChangeValueForKey:@"isLoadableImageLoading"];
}


- (void)startLoadingOperation
{
	DASSERT(_loadableImageURL && _loadableImageLoading && !_loadingOperation);
	DASSERT(!_loadingOperation);
	DASSERT(self.window && !self.needsUpdateMetric);
	
	typeof(self) __weak weakSelf = self;
	void (^completionHandler)(id<MBOperation>,UIImage*,NSError*) = ^(id<MBOperation> operation, UIImage *image, NSError *error)
	{
		typeof(self) strongSelf = weakSelf;
		if (strongSelf)
			[strongSelf _completeLoadingOperation:image error:error];
	};
	_loadingOperation = [[MBImagesService sharedService] queryImageWithURL:_loadableImageURL form:_imageForm metric:self.metric withEffect:_imageEffect completionHandler:completionHandler];
}


- (void)cancelLoadingOperation
{
	if (_loadingOperation)
	{
		[_loadingOperation cancel];
		_loadingOperation = nil;
	}
}


- (void)resetLoadableImage
{
	if (_loadingOperation)
	{
		[_loadingOperation cancel];
		_loadingOperation = nil;
	}
	_loadableImageURL = nil;
	_loadableImageFailed = NO;
	_loadableImageSize = CGSizeZero;
	if (_loadableImageLoading)
	{
		[self willChangeValueForKey:@"isLoadableImageLoading"];
		_loadableImageLoading = NO;
		[self didChangeValueForKey:@"isLoadableImageLoading"];
	}
}


@end

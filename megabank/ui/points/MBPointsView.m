//
//  MBPointsView.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsView.h"



@implementation MBPointsView


+ (NSString*)identifier
{
	return @"Points";
}


- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]))
	{
		_baseView = [[UIImageView alloc] init];
		_baseView.contentMode = UIViewContentModeCenter;
		[self addSubview:_baseView];
		
		_conglomerateView = [[MBConglomerateView alloc] initWithImageForm:MBImageFormCardSlice];
		_conglomerateView.adjustsWhenHighlighted = YES;
		[self addSubview:_conglomerateView];
	}
	return self;
}


+ (UIImage*)pinImageForMetric:(MBMetric)metric
{
	static UIImage *Images[MBMetricCount] = { 0 };	// Вообще-то нехорошо хранить картинки так, обычно я храню их централизовано в авто-очищающемся кэше, ну да ладно...
	UIImage *image = Images[metric];
	if (!image)
	{
		CGSize size = [MBImageView preferredViewSizeForMetric:metric withImageForm:MBImageFormCardSlice];
		CGFloat radius = size.width / 2 + FRAME_WIDTH;
		image = [UIImage pinImage:radius color:nil];
		image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		Images[metric] = image;
	}
	return image;
}


+ (CGPoint)pinImageAnchorOffsetForMetric:(MBMetric)metric
{
	CGSize size = [MBImageView preferredViewSizeForMetric:metric withImageForm:MBImageFormCardSlice];
	CGFloat radius = size.width / 2 + FRAME_WIDTH;
	CGSize pinSize = [UIImage pinImageSize:radius];
	pinSize = CGSizeIntegral(pinSize);
	CGPoint offset = CGPointZero;
	offset.y -= pinSize.height / 2;
	return offset;
}


- (void)updateMetric
{
	[super updateMetric];
	_baseView.image = [MBPointsView pinImageForMetric:self.metric];
	CGSize baseSize = _baseView.image.size;
	_baseView.bounds = (CGRect){.origin = CGPointZero, .size = baseSize};
	self.centerOffset = [MBPointsView pinImageAnchorOffsetForMetric:self.metric];
	_conglomerateView.bounds = (CGRect){.origin = CGPointZero, .size = [MBConglomerateView preferredViewSizeForMetric:self.metric withImageForm:MBImageFormCardSlice]};
	self.bounds = (CGRect){.origin = CGPointZero, .size = baseSize};
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect bounds = self.bounds;
	CGPoint center = CGRectGetCenter(bounds);
	_baseView.center = center;
	CGSize offset = CGSizeZero;
	CGSize pinSize = _baseView.image ? _baseView.image.size : [MBPointsView preferredViewSizeForMetric:self.metric];
	offset.height -= (pinSize.height - pinSize.width) / 2;
	_conglomerateView.center = CGPointOffset(center, offset);
}


+ (CGSize)preferredViewSizeForMetric:(MBMetric)metric
{
	return [MBPointsView pinImageForMetric:metric].size;
}


- (CGRect)pointsAreaFrame
{
	return _conglomerateView.frame;
}


- (void)setPointURL:(NSURL *)pointURL
{
	[_conglomerateView setImagesURLs:pointURL ? [NSArray arrayWithObject:pointURL] : nil withPlaceholder:nil];
}


- (void)setPointsURLs:(NSArray<NSURL*>*)pointsURLs withPlaceholder:(NSString*)placeholder
{
	[_conglomerateView setImagesURLs:pointsURLs withPlaceholder:placeholder];
}


- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	_conglomerateView.highlighted = highlighted;
}


@end



@implementation MBPointsView (MBMPoint)


- (void)setMBMPoints:(NSArray<MBMPoint*>*)points
{
	NSUInteger pointsCount = points ? points.count : 0;
	NSString *placeholder = nil;
	if (pointsCount > [MBConglomerateView maximumPresentedImagesWithPlaceholder:NO])
	{
		pointsCount = [MBConglomerateView maximumPresentedImagesWithPlaceholder:YES];
		NSUInteger placeholderNumber = points.count - pointsCount;
		placeholder = placeholderNumber < 1000 ? [NSString stringWithFormat:@"+%lu", (unsigned long) placeholderNumber] : @"...";
	}
	NSMutableArray<NSURL*> *pointsURLs = [[NSMutableArray alloc] initWithCapacity:pointsCount];
	for (NSUInteger i = 0; i < pointsCount; ++i)
	{
		MBMPoint *point = (MBMPoint*)[points objectAtIndex:i];
		[pointsURLs addObject:point.partner.logoURL ?: (id)[NSNull null]];
	}
	[self setPointsURLs:pointsURLs withPlaceholder:placeholder];
}


@end

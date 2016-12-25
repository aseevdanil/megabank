//
//  MBView.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBView.h"


// Конечно тут можно задействовать swizzling, чтобы уменьшить колличество кода, но я считаю что пользоваться swizzling нужно только в экстренных случаях, это не такой случай!
// Кроме того, помимо понятия metric, в UIView и его сабклассы часто бывает полезно вводить другие определения, специфичные для приложения, все это можно сделать здесь!


@implementation MBView


- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		_mbviewFlags.metric = MBMetricCompact;
		_mbviewFlags.needsUpdateMetric = YES;
		[self setNeedsLayout];
	}
	return self;
}


- (MBMetric)metric
{
	return _mbviewFlags.metric;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	MBMetric newMetric = self.traitCollection.metric;
	if (newMetric != _mbviewFlags.metric)
	{
		_mbviewFlags.metric = newMetric;
		_mbviewFlags.needsUpdateMetric = YES;
		[self setNeedsLayout];
	}
}


- (void)updateMetric
{
	DASSERT(!_mbviewFlags.needsUpdateMetric);
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	if (_mbviewFlags.needsUpdateMetric)
	{
		_mbviewFlags.needsUpdateMetric = NO;
		[self updateMetric];
	}
}


- (CGSize)sizeThatFits:(CGSize)size
{
	if (_mbviewFlags.needsUpdateMetric)
	{
		_mbviewFlags.needsUpdateMetric = NO;
		[self updateMetric];
	}
	return [super sizeThatFits:size];
}


@end



@implementation MBImageBaseView


- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		_mbviewFlags.metric = MBMetricCompact;
		_mbviewFlags.needsUpdateMetric = YES;
		[self setNeedsLayout];
	}
	return self;
}


- (MBMetric)metric
{
	return _mbviewFlags.metric;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	MBMetric newMetric = self.traitCollection.metric;
	if (newMetric != _mbviewFlags.metric)
	{
		_mbviewFlags.metric = newMetric;
		_mbviewFlags.needsUpdateMetric = YES;
		[self setNeedsLayout];
		[self didChangeMetric];
	}
}


- (void)didChangeMetric
{
}


- (BOOL)needsUpdateMetric
{
	return _mbviewFlags.needsUpdateMetric;
}


- (void)updateMetric
{
	DASSERT(!_mbviewFlags.needsUpdateMetric);
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	if (_mbviewFlags.needsUpdateMetric)
	{
		_mbviewFlags.needsUpdateMetric = NO;
		[self updateMetric];
	}
}


- (CGSize)sizeThatFits:(CGSize)size
{
	if (_mbviewFlags.needsUpdateMetric)
	{
		_mbviewFlags.needsUpdateMetric = NO;
		[self updateMetric];
	}
	return [super sizeThatFits:size];
}


@end



@implementation MBButton


- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		_mbviewFlags.metric = MBMetricCompact;
		_mbviewFlags.needsUpdateMetric = YES;
		[self setNeedsLayout];
	}
	return self;
}


- (MBMetric)metric
{
	return _mbviewFlags.metric;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	MBMetric newMetric = self.traitCollection.metric;
	if (newMetric != _mbviewFlags.metric)
	{
		_mbviewFlags.metric = newMetric;
		_mbviewFlags.needsUpdateMetric = YES;
		[self setNeedsLayout];
	}
}


- (void)updateMetric
{
	DASSERT(!_mbviewFlags.needsUpdateMetric);
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	if (_mbviewFlags.needsUpdateMetric)
	{
		_mbviewFlags.needsUpdateMetric = NO;
		[self updateMetric];
	}
}


- (CGSize)sizeThatFits:(CGSize)size
{
	if (_mbviewFlags.needsUpdateMetric)
	{
		_mbviewFlags.needsUpdateMetric = NO;
		[self updateMetric];
	}
	return [super sizeThatFits:size];
}


@end



@implementation MBAnnotationView


- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]))
	{
		_mbviewFlags.metric = MBMetricCompact;
		_mbviewFlags.needsUpdateMetric = YES;
		[self setNeedsLayout];
	}
	return self;
}


- (MBMetric)metric
{
	return _mbviewFlags.metric;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	MBMetric newMetric = self.traitCollection.metric;
	if (newMetric != _mbviewFlags.metric)
	{
		_mbviewFlags.metric = newMetric;
		_mbviewFlags.needsUpdateMetric = YES;
		[self setNeedsLayout];
	}
}


- (void)updateMetric
{
	DASSERT(!_mbviewFlags.needsUpdateMetric);
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	if (_mbviewFlags.needsUpdateMetric)
	{
		_mbviewFlags.needsUpdateMetric = NO;
		[self updateMetric];
	}
}


- (CGSize)sizeThatFits:(CGSize)size
{
	if (_mbviewFlags.needsUpdateMetric)
	{
		_mbviewFlags.needsUpdateMetric = NO;
		[self updateMetric];
	}
	return [super sizeThatFits:size];
}


@end

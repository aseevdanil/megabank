//
//  MBMapControlsView.m
//  megabank
//
//  Created by da on 04.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBMapControlsView.h"



@interface MBMapControlsView ()

- (void)regItem:(MBMapButtonItem*)item;
- (void)unregItem:(MBMapButtonItem*)item;

@end


@implementation MBMapControlsView


- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = NO;
		
		_loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_loadingView.hidesWhenStopped = YES;
		[self addSubview:_loadingView];
	}
	return self;
}


- (void)dealloc
{
	if (_scaleUpButton)
		[self unregItem:_scaleUpButtonItem];
	if (_scaleDownButton)
		[self unregItem:_scaleDownButtonItem];
}


- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (![super hitTest:point withEvent:event])
		return nil;
	if (_scaleUpButton && CGRectContainsPoint(_scaleUpButton.frame, point))
		return _scaleUpButton;
	if (_scaleDownButton && CGRectContainsPoint(_scaleDownButton.frame, point))
		return _scaleDownButton;
	return nil;
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	CGSize margins = MBMetricTable[self.metric].boundsMargins, spacing = MBMetricTable[self.metric].itemsSpacing;
	CGRect bounds = CGRectInset(self.bounds, margins.width, margins.height);
	_loadingView.center = CGRectGetCenter(bounds);
	CGRect buttonFrame = bounds;
	buttonFrame.size = [MBMapButton preferredButtonSizeForMetric:self.metric];
	buttonFrame.origin.y += bounds.size.height - buttonFrame.size.height;
	if (_scaleDownButton)
	{
		_scaleDownButton.center = CGRectGetCenter(buttonFrame);
		buttonFrame.origin.y -= spacing.height + buttonFrame.size.height;
	}
	if (_scaleUpButton)
		_scaleUpButton.center = CGRectGetCenter(buttonFrame);
}


- (BOOL)isLoading
{
	return _loadingView.isAnimating;
}


- (void)setLoading:(BOOL)loading
{
	if (loading)
	{
		[_loadingView startAnimating];
		self.backgroundColor = [UIColor colorWithWhite:.3 alpha:.3];
	}
	else
	{
		[_loadingView stopAnimating];
		self.backgroundColor = [UIColor clearColor];
	}
}


#pragma mark Buttons


@synthesize scaleUpButtonItem = _scaleUpButtonItem, scaleDownButtonItem = _scaleDownButtonItem;


static char MBMapControlsViewContext;


- (void)regItem:(MBMapButtonItem*)item
{
	DASSERT(item);
	[item addObserver:self forKeyPath:@"hidden" options:0 context:&MBMapControlsViewContext];
	[item addObserver:self forKeyPath:@"enabled" options:0 context:&MBMapControlsViewContext];
}


- (void)unregItem:(MBMapButtonItem*)item
{
	[item removeObserver:self forKeyPath:@"hidden" context:&MBMapControlsViewContext];
	[item removeObserver:self forKeyPath:@"enabled" context:&MBMapControlsViewContext];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == &MBMapControlsViewContext)
	{
		if (object == _scaleUpButtonItem || object == _scaleDownButtonItem)
		{
			MBMapButton *button = object == _scaleDownButtonItem ? _scaleDownButton : _scaleUpButton;
			if ([keyPath isEqualToString:@"enabled"])
				button.enabled = ((MBMapButtonItem*) object).isEnabled;
			else if ([keyPath isEqualToString:@"hidden"])
				button.hidden = ((MBMapButtonItem*) object).isHidden;
		}
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}



- (void)setScaleUpButtonItem:(MBMapButtonItem *)scaleUpButtonItem
{
	if (_scaleUpButtonItem)
	{
		[self unregItem:_scaleUpButtonItem];
		_scaleUpButtonItem = nil;
		[_scaleUpButton removeFromSuperview];
		_scaleUpButton = nil;
	}
	_scaleUpButtonItem = scaleUpButtonItem;
	if (_scaleUpButtonItem)
	{
		[self regItem:_scaleUpButtonItem];
		_scaleUpButton = [[MBMapButton alloc] initWithType:MBMapButtonTypeScaleUp];
		_scaleUpButton.enabled = _scaleUpButtonItem.isEnabled;
		_scaleUpButton.hidden = _scaleUpButtonItem.isHidden;
		[_scaleUpButton addTarget:self action:@selector(handleScaleUpButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_scaleUpButton];
	}
	[self setNeedsLayout];
}


- (void)setScaleDownButtonItem:(MBMapButtonItem *)scaleDownButtonItem
{
	if (_scaleDownButtonItem)
	{
		[self unregItem:_scaleDownButtonItem];
		_scaleDownButtonItem = nil;
		[_scaleDownButton removeFromSuperview];
		_scaleDownButton = nil;
	}
	_scaleDownButtonItem = scaleDownButtonItem;
	if (_scaleUpButtonItem)
	{
		[self regItem:_scaleDownButtonItem];
		_scaleDownButton = [[MBMapButton alloc] initWithType:MBMapButtonTypeScaleDown];
		_scaleDownButton.enabled = _scaleDownButtonItem.isEnabled;
		_scaleDownButton.hidden = _scaleDownButtonItem.isHidden;
		[_scaleDownButton addTarget:self action:@selector(handleScaleDownButton:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_scaleDownButton];
	}
	[self setNeedsLayout];
}


- (void)handleScaleUpButton:(id)sender
{
	if (!self.isLoading)
		SAFE_CALL_WEAK_TARGET_METHOD_WITH_OBJECT(_scaleUpButtonItem.target, _scaleUpButtonItem.action, _scaleUpButtonItem)
}


- (void)handleScaleDownButton:(id)sender
{
	if (!self.isLoading)
		SAFE_CALL_WEAK_TARGET_METHOD_WITH_OBJECT(_scaleDownButtonItem.target, _scaleDownButtonItem.action, _scaleDownButtonItem)
}


@end

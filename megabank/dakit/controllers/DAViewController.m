//
//  DAViewController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "DAViewController.h"



#pragma mark Helpers


@interface DAViewController_AnchorInsetsMaskLayer : CAShapeLayer
{
	UIEdgeInsets _insets;
	CGFloat _insetsAlpha;
}

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGFloat insetsAlpha;

@end


@implementation DAViewController_AnchorInsetsMaskLayer


@synthesize insets = _insets, insetsAlpha = _insetsAlpha;


- (instancetype)init
{
	if ((self = [super init]))
	{
		_insets = UIEdgeInsetsZero;
		_insetsAlpha = 1.;
		self.needsDisplayOnBoundsChange = YES;
		self.backgroundColor = [UIColor colorWithWhite:0. alpha:_insetsAlpha].CGColor;
	}
	return self;
}


- (id<CAAction>)actionForKey:(NSString *)event
{
	return [NSNull null];
}


- (void)display
{
	[super display];
	CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, _insets);
	CGPathRef path = CGPathCreateWithRect(bounds, NULL);
	self.path = path;
	CGPathRelease(path);
}


- (void)setInsetsAlpha:(CGFloat)insetsAlpha
{
	if (insetsAlpha < 0.)
		insetsAlpha = 0.;
	else if (insetsAlpha > 1.)
		insetsAlpha = 1.;
	if (insetsAlpha == _insetsAlpha)
		return;
	_insetsAlpha = insetsAlpha;
	self.backgroundColor = [UIColor colorWithWhite:0. alpha:_insetsAlpha].CGColor;
}


- (void)setInsets:(UIEdgeInsets)insets
{
	if (UIEdgeInsetsEqualToEdgeInsets(insets, _insets))
		return;
	_insets = insets;
	[self setNeedsDisplay];
}


@end


@interface DAViewController_AnchorView : UIView
{
	id __weak _layoutSubviewsDelegate;
	SEL _layoutSubviewsSelector;
}

@property (nonatomic, assign) UIEdgeInsets maskInsets;
@property (nonatomic, assign) CGFloat maskInsetsAlpha;

@property (nonatomic, weak) id layoutSubviewsDelegate;
@property (nonatomic, assign) SEL layoutSubviewsSelector;

@end


@implementation DAViewController_AnchorView


@synthesize layoutSubviewsDelegate = _layoutSubviewsDelegate, layoutSubviewsSelector = _layoutSubviewsSelector;


- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		DAViewController_AnchorInsetsMaskLayer *maskLayer = [[DAViewController_AnchorInsetsMaskLayer alloc] init];
		self.layer.mask = maskLayer;
	}
	return self;
}


- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	[super layoutSublayersOfLayer:layer];
	if (layer == self.layer)
	{
		self.layer.mask.frame = self.layer.bounds;
	}
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	SAFE_CALL_WEAK_TARGET_METHOD(_layoutSubviewsDelegate, _layoutSubviewsSelector)
}


- (UIEdgeInsets)maskInsets
{
	return ((DAViewController_AnchorInsetsMaskLayer*) self.layer.mask).insets;
}


- (void)setMaskInsets:(UIEdgeInsets)maskInsets
{
	((DAViewController_AnchorInsetsMaskLayer*) self.layer.mask).insets = maskInsets;
}


- (CGFloat)maskInsetsAlpha
{
	return ((DAViewController_AnchorInsetsMaskLayer*) self.layer.mask).insetsAlpha;
}


- (void)setMaskInsetsAlpha:(CGFloat)maskInsetsAlpha
{
	((DAViewController_AnchorInsetsMaskLayer*) self.layer.mask).insetsAlpha = maskInsetsAlpha;
}


@end



@interface DAViewController_ContentView : UIView
{
	id __weak _layoutSubviewsDelegate;
	SEL _layoutSubviewsSelector;
}

@property (nonatomic, weak) id layoutSubviewsDelegate;
@property (nonatomic, assign) SEL layoutSubviewsSelector;

@end


@implementation DAViewController_ContentView


@synthesize layoutSubviewsDelegate = _layoutSubviewsDelegate, layoutSubviewsSelector = _layoutSubviewsSelector;


- (void)layoutSubviews
{
	[super layoutSubviews];
	SAFE_CALL_WEAK_TARGET_METHOD(_layoutSubviewsDelegate, _layoutSubviewsSelector)
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *hitView = [super hitTest:point withEvent:event];
	return hitView != self ? hitView : nil;
}


@end




#pragma mark -


@interface DAViewController ()
{
	UIView *_backgroundView;
	DAViewController_AnchorView *_anchorView;
	DAViewController_ContentView *_contentView;
	
	CGFloat _anchorInsetsMaskAlpha;
}

@end


@implementation DAViewController


@synthesize backgroundView = _backgroundView;
@synthesize anchorView = _anchorView;
@synthesize anchorInsetsMaskAlpha = _anchorInsetsMaskAlpha;
@synthesize contentView = _contentView;


- (instancetype)init
{
	if ((self = [super init]))
	{
		_anchorInsetsMaskAlpha = 1.;
		
		self.extendedLayoutIncludesOpaqueBars = YES;
		self.automaticallyAdjustsScrollViewInsets = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
	BOOL clearView = [self isViewLoaded] && !self.view.window && !self.presentedViewController && !self.presentingViewController;
	if (clearView)
		[self viewWillClear];
	
	[super didReceiveMemoryWarning];
	
	if (clearView)
		self.view = nil;
	
	if (clearView)
		[self viewDidClear];
}


- (void)applicationDidEnterBackground:(NSNotification*)notification
{
	BOOL clearView = [self isViewLoaded] && !self.view.window && !self.presentedViewController && !self.presentingViewController;
	if (clearView)
	{
		[self viewWillClear];
		self.view = nil;
		[self viewDidClear];
	}
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self loadBackgroundView];
	
	_anchorView = [[DAViewController_AnchorView alloc] initWithFrame:self.view.bounds];
	_anchorView.layoutSubviewsDelegate = self;
	_anchorView.layoutSubviewsSelector = @selector(handleAnchorViewDidLayoutSubviews);
	_anchorView.maskInsetsAlpha = _anchorInsetsMaskAlpha;
	[self.view addSubview:_anchorView];
	
	_contentView = [[DAViewController_ContentView alloc] initWithFrame:self.view.bounds];
	_contentView.opaque = NO;
	_contentView.backgroundColor = [UIColor clearColor];
	_contentView.layoutSubviewsDelegate = self;
	_contentView.layoutSubviewsSelector = @selector(handleContentViewDidLayoutSubviews);
	[self.view addSubview:_contentView];
}


- (void)viewDidClear
{
	[super viewDidClear];
	_contentView = nil;
	_anchorView = nil;
	_backgroundView = nil;
}


- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	CGRect bounds = self.view.bounds;
	if (_backgroundView)
		_backgroundView.frame = bounds;
	_anchorView.frame = bounds;
	_contentView.frame = UIEdgeInsetsInsetRect(bounds, self.anchorViewInsets);
}


- (void)handleAnchorViewDidLayoutSubviews
{
	DASSERT(self.isViewLoaded);
	_anchorView.maskInsets = self.anchorViewInsets;
	[self anchorViewDidLayoutSubviews];
}


- (void)handleContentViewDidLayoutSubviews
{
	DASSERT(self.isViewLoaded);
	[self contentViewDidLayoutSubviews];
}


- (void)anchorViewDidLayoutSubviews
{
	DASSERT(self.isViewLoaded);
}


- (void)contentViewDidLayoutSubviews
{
	DASSERT(self.isViewLoaded);
}


- (UIEdgeInsets)anchorViewInsets
{
	UIEdgeInsets insets = UIEdgeInsetsZero;
	insets.top = self.topLayoutGuide.length;
	insets.bottom = self.bottomLayoutGuide.length;
	return insets;
}


- (void)setAnchorInsetsMaskAlpha:(CGFloat)anchorInsetsMaskAlpha
{
	if (anchorInsetsMaskAlpha < 0.)
		anchorInsetsMaskAlpha = 0.;
	else if (anchorInsetsMaskAlpha > 1.)
		anchorInsetsMaskAlpha = 1.;
	_anchorInsetsMaskAlpha = anchorInsetsMaskAlpha;
	if ([self isViewLoaded])
		_anchorView.maskInsetsAlpha = _anchorInsetsMaskAlpha;
}


- (void)setBackgroundView:(UIView *)backgroundView
{
	DASSERT(self.isViewLoaded);
	DASSERT(!_backgroundView);
	_backgroundView = backgroundView;
	if (_backgroundView)
	{
		_backgroundView.frame = self.view.bounds;
		[self.view insertSubview:_backgroundView atIndex:0];
	}
}


- (void)reloadBackgroundView
{
	if (self.isViewLoaded)
	{
		if (_backgroundView)
		{
			[_backgroundView removeFromSuperview];
			_backgroundView = nil;
		}
		[self loadBackgroundView];
	}
}


- (void)loadBackgroundView
{
}


@end

//
//  MBPointsPanel.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsPanel.h"

#import "MBPointsPanelPointViewCell.h"



@interface MBPointsPanel () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

+ (CGSize)preferredPanelSize:(NSUInteger)numberOfPoints forMetric:(MBMetric)metric maxSize:(CGSize)maxSize;
+ (CGPoint)preferredPanelPosition:(CGSize)panelSize inFrame:(CGRect)frame anchorRect:(CGRect)anchorRect forMetric:(MBMetric)metric;

@end


@implementation MBPointsPanel


#pragma mark Base


@synthesize pointsPanelDataSource = _pointsPanelDataSource, pointsPanelDelegate = _pointsPanelDelegate;


- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		_presented = NO;
		_panelAnchorRect = CGRectNull;
		
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = NO;
		
		_backgroundView = [[UIView alloc] init];
		_backgroundView.opaque = NO;
		_backgroundView.backgroundColor = [UIColor colorWithWhite:.0 alpha:.33];
		_backgroundView.hidden = YES;
		[self addSubview:_backgroundView];
		
		_panelBaseView = [[UIView alloc] init];
		_panelBaseView.opaque = NO;
		_panelBaseView.backgroundColor = [UIColor MBBackgroundColor];
		_panelBaseView.layer.mask = [[CAShapeLayer alloc] init];
		_panelBaseView.hidden = YES;
		[self addSubview:_panelBaseView];
		
		UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
		collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
		_contentView = [[UICollectionView alloc] initWithFrame:_panelBaseView.bounds collectionViewLayout:collectionLayout];
		_contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_contentView.opaque = NO;
		_contentView.backgroundColor = [UIColor clearColor];
		_contentView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
		[_contentView registerClass:[MBPointsPanelPointViewCell class] forCellWithReuseIdentifier:[MBPointsPanelPointViewCell identifier]];
		_contentView.dataSource = self;
		_contentView.delegate = self;
		[_panelBaseView addSubview:_contentView];
		
		_panelVerticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
		_panelHorizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
		UIMotionEffectGroup *panelMotionEffect = [[UIMotionEffectGroup alloc] init];
		panelMotionEffect.motionEffects = [NSArray arrayWithObjects:_panelVerticalMotionEffect, _panelHorizontalMotionEffect, nil];
		[_panelBaseView addMotionEffect:panelMotionEffect];
		
		_dismissGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissGestureRecognizer:)];
		((UILongPressGestureRecognizer*) _dismissGestureRecognizer).minimumPressDuration = .01;
		((UILongPressGestureRecognizer*) _dismissGestureRecognizer).allowableMovement = CGFLOAT_MAX;
		_dismissGestureRecognizer.delegate = self;
		_dismissGestureRecognizer.enabled = NO;
		[self addGestureRecognizer:_dismissGestureRecognizer];
	}
	return self;
}


- (void)updateMetric
{
	[super updateMetric];
	CGSize spacing = [MBPointsPanelPointViewCell itemsSpacingForMetric:self.metric];
	CGSize itemSize = [MBPointsPanelPointViewCell itemSizeForMetric:self.metric];
	((UICollectionViewFlowLayout*) _contentView.collectionViewLayout).sectionInset = UIEdgeInsetsMake(spacing.height, spacing.width, spacing.height, spacing.width);
	((UICollectionViewFlowLayout*) _contentView.collectionViewLayout).itemSize = itemSize;
	((UICollectionViewFlowLayout*) _contentView.collectionViewLayout).minimumInteritemSpacing = spacing.width;
	((UICollectionViewFlowLayout*) _contentView.collectionViewLayout).minimumLineSpacing = spacing.height;
}


- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	[super layoutSublayersOfLayer:layer];
	if (layer == self.layer)
	{
		CGRect panelBounds = _panelBaseView.layer.bounds;
		_panelBaseView.layer.mask.frame = panelBounds;
		CGPathRef maskPath = CGPathCreateWithRoundedRect(panelBounds, 11., 11., NULL);
		((CAShapeLayer*) _panelBaseView.layer.mask).path = maskPath;
		CGPathRelease(maskPath);
	}
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect bounds = self.bounds;
	_backgroundView.frame = bounds;
	
	CGSize panelSize = [MBPointsPanel preferredPanelSize:[_contentView numberOfSections] > 0 ? [_contentView numberOfItemsInSection:0] : 0 forMetric:self.metric maxSize:bounds.size];
	_panelBaseView.bounds = (CGRect){.origin = CGPointZero, .size = panelSize};
	_panelBaseView.center = [MBPointsPanel preferredPanelPosition:panelSize inFrame:bounds anchorRect:_panelAnchorRect forMetric:self.metric];
	
	CGFloat verticalRelativeValue = panelSize.height / 14., horizontalRelativeValue = panelSize.width / 14.;
	_panelVerticalMotionEffect.minimumRelativeValue = [NSNumber numberWithDouble:-verticalRelativeValue];
	_panelVerticalMotionEffect.maximumRelativeValue = [NSNumber numberWithDouble:verticalRelativeValue];
	_panelHorizontalMotionEffect.minimumRelativeValue = [NSNumber numberWithDouble:-horizontalRelativeValue];
	_panelHorizontalMotionEffect.maximumRelativeValue = [NSNumber numberWithDouble:horizontalRelativeValue];
}


+ (CGSize)preferredPanelSize:(NSUInteger)numberOfPoints forMetric:(MBMetric)metric maxSize:(CGSize)maxSize
{
	if (numberOfPoints == 0)
		return CGSizeZero;
	
#define kMBPointsPanel_MaximumNumberOfRows 4
#define kMBPointsPanel_MaximumNumberOfLines 4
	
	CGSize spacing = [MBPointsPanelPointViewCell itemsSpacingForMetric:metric];
	maxSize.width -= spacing.width + spacing.width;
	maxSize.height -= spacing.height + spacing.height;
	
	CGSize itemSize = [MBPointsPanelPointViewCell itemSizeForMetric:metric];
	CGSize itemsSpacing = [MBPointsPanelPointViewCell itemsSpacingForMetric:metric];
	NSUInteger maxRows = (maxSize.width + itemsSpacing.width) / (itemSize.width + itemsSpacing.width), maxLines = (maxSize.height + itemsSpacing.height) / (itemSize.height + itemsSpacing.height);
	NSUInteger rows = MAX(MIN(maxRows, kMBPointsPanel_MaximumNumberOfRows), 1), lines = MAX(MIN(maxLines, kMBPointsPanel_MaximumNumberOfLines), 1);
	NSUInteger maximumNumberOfPoints = rows * lines;
	if (numberOfPoints < maximumNumberOfPoints)
	{
		lines = (numberOfPoints + rows - 1) / rows;
		while (numberOfPoints <= (rows - 1) * lines)
			--rows;
	}
	CGFloat width = rows * (itemSize.width + itemsSpacing.width) - itemsSpacing.width, height = lines * (itemSize.height + itemsSpacing.height) - itemsSpacing.height;
	width += spacing.width + spacing.width;
	height += spacing.height + spacing.height;
	return CGSizeMake(width, height);
}


+ (CGPoint)preferredPanelPosition:(CGSize)panelSize inFrame:(CGRect)frame anchorRect:(CGRect)anchorRect forMetric:(MBMetric)metric
{
	if (CGRectIsNull(anchorRect))
		return CGRectGetCenter(frame);
	
	CGSize itemsSpacing = [MBPointsPanelPointViewCell itemsSpacingForMetric:metric];
	frame = CGRectInset(frame, itemsSpacing.width, itemsSpacing.height);
	CGSize insets = CGSizeZero;
	anchorRect.origin.x -= insets.width;
	anchorRect.origin.y -= insets.height;
	anchorRect.size.width += 2 * insets.width;
	anchorRect.size.height += 2 * insets.height;
	
	CGRect panelFrame = frame;
	panelFrame.size = panelSize;
	CGFloat leftSpacingWidth = anchorRect.origin.x - frame.origin.x, topSpacingHeight = anchorRect.origin.y - frame.origin.y;
	CGFloat rightSpacingWidth = (frame.origin.x + frame.size.width) - (anchorRect.origin.x + anchorRect.size.width), bottomSpacingHeight = (frame.origin.y + frame.size.height) - (anchorRect.origin.y + anchorRect.size.height);
	if (leftSpacingWidth < rightSpacingWidth)
		panelFrame.origin.x = anchorRect.origin.x + anchorRect.size.width;
	else
		panelFrame.origin.x = anchorRect.origin.x - panelFrame.size.width;
	if (topSpacingHeight < bottomSpacingHeight)
		panelFrame.origin.y = anchorRect.origin.y + anchorRect.size.height;
	else
		panelFrame.origin.y = anchorRect.origin.y - panelFrame.size.height;
	
	if (panelFrame.origin.x < frame.origin.x || frame.origin.x + frame.size.width < panelFrame.origin.x + panelFrame.size.width)
	{
		if (panelFrame.size.width > frame.size.width)
		{
			panelFrame.origin.x = frame.origin.x + (frame.size.width - panelFrame.size.width) / 2;
		}
		else
		{
			if (panelFrame.origin.x < frame.origin.x)
				panelFrame.origin.x = frame.origin.x;
			else
				panelFrame.origin.x = (frame.origin.x + frame.size.width) - panelFrame.size.width;
		}
	}
	if (panelFrame.origin.y < frame.origin.y || frame.origin.y + frame.size.height < panelFrame.origin.y + panelFrame.size.height)
	{
		if (panelFrame.size.height > frame.size.height)
		{
			panelFrame.origin.y = frame.origin.y + (frame.size.height - panelFrame.size.height) / 2;
		}
		else
		{
			if (panelFrame.origin.y < frame.origin.y)
				panelFrame.origin.y = frame.origin.y;
			else
				panelFrame.origin.y = (frame.origin.y + frame.size.height) - panelFrame.size.height;
		}
	}
	return CGRectGetCenter(panelFrame);
}


#pragma mark Content


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	id strongDataSource = _pointsPanelDataSource;
	return strongDataSource ? [strongDataSource pointsPanelNumberOfPoints:self] : 0;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	id strongDataSource = _pointsPanelDataSource;
	NSURL *pointURL = strongDataSource ? [strongDataSource pointsPanel:self pointURLAtIndex:indexPath.row] : nil;
	MBPointsPanelPointViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MBPointsPanelPointViewCell identifier] forIndexPath:indexPath];
	[cell setPointURL:pointURL];
	return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	id strongDelegate = _pointsPanelDelegate;
	if (strongDelegate)
		[strongDelegate pointsPanel:self didSelectPointAtIndex:indexPath.row];
}


- (void)reloadData
{
	[_contentView reloadData];
	[self setNeedsLayout];
}


#pragma mark Presenting


- (BOOL)isPresented
{
	return _presented;
}


- (void)cancelPresentAnimation
{
	CAAnimation *backgroundAnimation = [_backgroundView.layer animationForKey:@"present"];
	if (backgroundAnimation)
		[_backgroundView.layer removeAnimationForKey:@"present"];
	CAAnimation *presentAnimation = [_panelBaseView.layer animationForKey:@"present"];
	if (presentAnimation)
	{
		void (^completion)(BOOL) = (void(^)(BOOL))[presentAnimation valueForKey:@"completion"];
		[presentAnimation setValue:nil forKey:@"completion"];
		[_panelBaseView.layer removeAnimationForKey:@"present"];
		if (completion)
			completion(NO);
	}
}


- (void)presentPanelFromAnchorRect:(CGRect)anchorRect animated:(BOOL)animated completion:(void(^)(void))completionHandler
{
	DASSERT(!_presented);
	if (_presented)
	{
		if (!animated)
			[self cancelPresentAnimation];
		return;
	}
	
	[self cancelPresentAnimation];
	
	_presented = YES;
	_panelAnchorRect = anchorRect;
	void (^completion)(BOOL) = ^(BOOL finished)
	{
		if (completionHandler)
			completionHandler();
	};
	if (animated)
	{
#define kMBPointsPanel_PresentAnimationDuration .14
		[self layoutIfNeeded];
		CATransform3D transform = CATransform3DIdentity;
		CGPoint panelPosition = _panelBaseView.layer.position, anchorPosition = CGRectGetCenter(CGRectIsNull(_panelAnchorRect) ? _panelBaseView.layer.bounds : _panelAnchorRect);
		CGSize panelSize = _panelBaseView.layer.bounds.size, anchorSize = CGRectIsNull(_panelAnchorRect) ? CGSizeMultiply(_panelBaseView.layer.bounds.size, .05) : _panelAnchorRect.size;
		if (panelSize.width != 0. && panelSize.height != 0.)
		{
			transform = CATransform3DTranslate(transform, anchorPosition.x - panelPosition.x, anchorPosition.y - panelPosition.y, 1.);
			transform = CATransform3DScale(transform, anchorSize.width / panelSize.width, anchorSize.height / panelSize.height, 1.);
		}
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		_backgroundView.layer.opacity = 0.;
		_panelBaseView.layer.sublayerTransform = transform;
		_panelBaseView.layer.opacity = 0.;
		[CATransaction commit];
		CAKeyframeAnimation *backgroundAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		backgroundAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.], [NSNumber numberWithDouble:1.], [NSNumber numberWithDouble:1.], nil];
		backgroundAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.], [NSNumber numberWithDouble:1. / 3.], [NSNumber numberWithDouble:1.], nil];
		backgroundAnimation.duration = kMBPointsPanel_PresentAnimationDuration;
		backgroundAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		[_backgroundView.layer addAnimation:backgroundAnimation forKey:@"present"];
		_backgroundView.layer.opacity = 1.;
		CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
		transformAnimation.fromValue = [NSValue valueWithCATransform3D:transform];
		transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		opacityAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.], [NSNumber numberWithDouble:1.], [NSNumber numberWithDouble:1.], nil];
		opacityAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.], [NSNumber numberWithDouble:1. / 3.], [NSNumber numberWithDouble:1.], nil];
		CAAnimationGroup *presentAnimation = [CAAnimationGroup animation];
		presentAnimation.animations = [NSArray arrayWithObjects:transformAnimation, opacityAnimation, nil];
		presentAnimation.duration = kMBPointsPanel_PresentAnimationDuration;
		presentAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		[presentAnimation setValue:[completion copy] forKey:@"completion"];
		presentAnimation.delegate = (id<CAAnimationDelegate>) self;
		[_panelBaseView.layer addAnimation:presentAnimation forKey:@"present"];
		_panelBaseView.layer.sublayerTransform = CATransform3DIdentity;
		_panelBaseView.layer.opacity = 1.;
	}
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	_backgroundView.hidden = NO;
	_panelBaseView.hidden = NO;
	[CATransaction commit];
	_dismissGestureRecognizer.enabled = YES;
	if (!animated)
		completion(YES);
}


- (void)dismissPanel:(BOOL)animated completion:(void(^)(void))completionHandler
{
	if (!_presented)
	{
		if (!animated)
			[self cancelPresentAnimation];
		return;
	}
	
	[self cancelPresentAnimation];
	
	void (^completion)(BOOL) = ^(BOOL finished)
	{
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		_panelBaseView.hidden = YES;
		_panelBaseView.layer.sublayerTransform = CATransform3DIdentity;
		_panelBaseView.layer.opacity = 1.;
		_backgroundView.hidden = YES;
		_backgroundView.layer.opacity = 1.;
		[CATransaction commit];
		if (completionHandler)
			completionHandler();
	};
	if (animated)
	{
#define kMBPointsPanel_DismissAnimationDuration .14
		[self layoutIfNeeded];
		CATransform3D transform = CATransform3DIdentity;
		CGPoint panelPosition = _panelBaseView.layer.position, anchorPosition = CGRectGetCenter(CGRectIsNull(_panelAnchorRect) ? _panelBaseView.layer.bounds : _panelAnchorRect);
		CGSize panelSize = _panelBaseView.layer.bounds.size, anchorSize = CGRectIsNull(_panelAnchorRect) ? CGSizeMultiply(_panelBaseView.layer.bounds.size, .05) : _panelAnchorRect.size;
		if (panelSize.width != 0. && panelSize.height != 0.)
		{
			transform = CATransform3DTranslate(transform, anchorPosition.x - panelPosition.x, anchorPosition.y - panelPosition.y, 1.);
			transform = CATransform3DScale(transform, anchorSize.width / panelSize.width, anchorSize.height / panelSize.height, 1.);
		}
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		_backgroundView.layer.opacity = 1.;
		_panelBaseView.layer.sublayerTransform = CATransform3DIdentity;
		_panelBaseView.layer.opacity = 1.;
		[CATransaction commit];
		CAKeyframeAnimation *backgroundAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		backgroundAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithDouble:1.], [NSNumber numberWithDouble:1.], [NSNumber numberWithDouble:0.], nil];
		backgroundAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.], [NSNumber numberWithDouble:1 - (1. / 3.)], [NSNumber numberWithDouble:1.], nil];
		backgroundAnimation.duration = kMBPointsPanel_PresentAnimationDuration;
		backgroundAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		[_backgroundView.layer addAnimation:backgroundAnimation forKey:@"present"];
		_backgroundView.layer.opacity = 0.;
		CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
		transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
		transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
		CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		opacityAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithDouble:1.], [NSNumber numberWithDouble:1.], [NSNumber numberWithDouble:0.], nil];
		opacityAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.], [NSNumber numberWithDouble:1 - (1. / 3.)], [NSNumber numberWithDouble:1.], nil];
		CAAnimationGroup *presentAnimation = [CAAnimationGroup animation];
		presentAnimation.animations = [NSArray arrayWithObjects:transformAnimation, opacityAnimation, nil];
		presentAnimation.duration = kMBPointsPanel_DismissAnimationDuration;
		presentAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		[presentAnimation setValue:[completion copy] forKey:@"completion"];
		presentAnimation.delegate = (id<CAAnimationDelegate>) self;
		[_panelBaseView.layer addAnimation:presentAnimation forKey:@"present"];
		_panelBaseView.layer.sublayerTransform = transform;
		_panelBaseView.layer.opacity = 0.;
	}
	_presented = NO;
	_panelAnchorRect = CGRectNull;
	_dismissGestureRecognizer.enabled = NO;
	if (!animated)
		completion(YES);
}


- (void)repositionWithAnchorRect:(CGRect)anchorRect
{
	DASSERT(_presented);
	if (!_presented)
		return;
	
	_panelAnchorRect = anchorRect;
	[self setNeedsLayout];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	void (^completion)(BOOL) = (void(^)(BOOL))[anim valueForKey:@"completion"];
	if (completion)
		completion(flag);
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	DASSERT(_presented);
	if (!_presented)
		return NO;
	
	return !CGRectContainsPoint(_panelBaseView.frame, [touch locationInView:self]);
}


- (void)handleDismissGestureRecognizer:(UIGestureRecognizer*)gr
{
	if (gr.state != UIGestureRecognizerStateEnded)
		return;
	
	DASSERT(_presented);
	if (!_presented)
		return;
	
	id strongDelegate = _pointsPanelDelegate;
	if (strongDelegate && [strongDelegate pointsPanelShouldDismissPanel:self])
		[self dismissPanel:YES completion:^{ [strongDelegate pointsPanelDidDismissPanel:self]; }];
}


@end

//
//  MBPointsViewController+MBPointsPanel.m
//  megabank
//
//  Created by da on 04.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsViewController+MBPointsPanel.h"

#import "UIAlertController+MBMPoint.h"

#import "MBPointsView.h"



@interface MBPointsViewController ()
{
	id<MBPointsAnnotation> _pointsPanelAnnotation;
	MBPointsPanel *_pointsPanel;
	unsigned int _needUpdatePointsPanel : 1;
}

@end


@implementation MBPointsViewController (MBPointsPanel)


- (void)_destructPointsPanel
{
	[self resetNeedsUpdatePointsPanel];
	DASSERT(_pointsPanel && !_pointsPanel.isPresented);
	[_pointsPanel removeFromSuperview];
	_pointsPanel = nil;
	_pointsPanelAnnotation = nil;
}


- (void)presentPointsPanel:(BOOL)animation
{
	DASSERT(_pointsPanelAnnotation);
	if (!_pointsPanelAnnotation)
		return;
	
	DASSERT([self isMapViewReady]);
	
	DASSERT(!_pointsPanel);
	if (_pointsPanel)
		return;
	
	_pointsPanel = [[MBPointsPanel alloc] initWithFrame:self.contentView.bounds];
	_pointsPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_pointsPanel.pointsPanelDataSource = self;
	_pointsPanel.pointsPanelDelegate = self;
	[self.contentView addSubview:_pointsPanel];
	[_pointsPanel reloadData];
	
	CGRect anchorRect = CGRectNull;
	MBPointsView *pointsView = (MBPointsView*)[self.mapView viewForAnnotation:_pointsPanelAnnotation];
	if (pointsView)
		anchorRect = [self.contentView convertRect:[pointsView pointsAreaFrame] fromView:pointsView];
	[_pointsPanel presentPanelFromAnchorRect:anchorRect animated:animation completion:nil];
}


- (void)dismissPointsPanel:(BOOL)animated
{
	if (_pointsPanelAnnotation)
	{
		if (_pointsPanel)
			[_pointsPanel dismissPanel:animated completion:^{ [self _destructPointsPanel]; }];
		else
			_pointsPanelAnnotation = nil;
	}
}


- (void)updatePointsPanel
{
	[self resetNeedsUpdatePointsPanel];
	DASSERT(_pointsPanelAnnotation && _pointsPanel);
	if (_pointsPanel.isPresented)
	{
		CGRect anchorRect = CGRectNull;
		MBPointsView *pointsView = (MBPointsView*)[self.mapView viewForAnnotation:_pointsPanelAnnotation];
		if (pointsView)
			anchorRect = [self.contentView convertRect:[pointsView pointsAreaFrame] fromView:pointsView];
		[_pointsPanel repositionWithAnchorRect:anchorRect];
	}
}


- (void)setNeedsUpdatePointsPanel
{
	if (_pointsPanel)
	{
		if (!_needUpdatePointsPanel)
		{
			_needUpdatePointsPanel = YES;
			[self performSelector:@selector(_updatePointsPanelTimeoutFire) withObject:nil afterDelay:0.];
		}
	}
}


- (void)resetNeedsUpdatePointsPanel
{
	if (_needUpdatePointsPanel)
	{
		_needUpdatePointsPanel = NO;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updatePointsPanelTimeoutFire) object:nil];
	}
}


- (void)_updatePointsPanelTimeoutFire
{
	_needUpdatePointsPanel = NO;
	[self updatePointsPanel];
}


- (NSUInteger)pointsPanelNumberOfPoints:(MBPointsPanel*)pointsPanel
{
	DASSERT(_pointsPanelAnnotation);
	return _pointsPanelAnnotation ? _pointsPanelAnnotation.points.count : 0;
}


- (NSURL*)pointsPanel:(MBPointsPanel*)pointsPanel pointURLAtIndex:(NSUInteger)pointIndex
{
	DASSERT(_pointsPanelAnnotation);
	MBMPoint *point = (MBMPoint*) [_pointsPanelAnnotation.points objectAtIndex:pointIndex];
	return point.partner.logoURL;
}


- (void)pointsPanel:(MBPointsPanel*)pointsPanel didSelectPointAtIndex:(NSUInteger)pointIndex
{
	DASSERT(_pointsPanelAnnotation);
	MBMPoint *point = (MBMPoint*)[_pointsPanelAnnotation.points objectAtIndex:pointIndex];
	UIAlertController *alert = [UIAlertController alertControllerForPoint:point];
	[self presentViewController:alert animated:YES completion:nil];
	
	DASSERT(_pointsPanel);
	[_pointsPanel dismissPanel:YES completion:^{ [self _destructPointsPanel]; }];
}


- (BOOL)pointsPanelShouldDismissPanel:(MBPointsPanel*)pointsPanel
{
	return YES;
}


- (void)pointsPanelDidDismissPanel:(MBPointsPanel*)pointsPanel
{
	[self _destructPointsPanel];
}


@end

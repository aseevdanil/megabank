//
//  MBMapViewController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBMapViewController.h"



#define kMBMapViewController_AnnotationInsertDeleteAnimationDuration .25



@interface MBMapViewController ()
{
	unsigned int _withoutBackground : 1;
}

@end


@implementation MBMapViewController


- (instancetype)init
{
	if ((self = [super init]))
	{
		_withoutBackground = NO;
		self.anchorInsetsMaskAlpha = kMBViewController_AnchorInsetsMaskAlpha;
	}
	return self;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
	return MBStatusBarStyle;
}


- (void)loadBackgroundView
{
	if (!_withoutBackground)
		self.backgroundView = [[MBBackgroundView alloc] init];
}


- (BOOL)isWithoutBackground
{
	return _withoutBackground;
}


- (void)setWithoutBackground:(BOOL)withoutBackground
{
	if (withoutBackground == _withoutBackground)
		return;
	_withoutBackground = withoutBackground;
	[self reloadBackgroundView];
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
	for (MKAnnotationView *view in views)
	{
		if (view.annotation != mapView.userLocation)
		{
			view.alpha = 0.;
			[UIView animateWithDuration:kMBMapViewController_AnnotationInsertDeleteAnimationDuration delay:0. options:UIViewAnimationOptionCurveEaseIn animations:^{ view.alpha = 1.; } completion:nil];
		}
	}
}


@end



@implementation MKMapView (AnimatedAnnotations)


- (void)removeAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated
{
	if (!animated)
	{
		[self removeAnnotation:annotation];
		return;
	}
	MKAnnotationView *annotationView = [self viewForAnnotation:annotation];
	if (!annotationView)
	{
		[self removeAnnotation:annotation];
		return;
	}
	[UIView animateWithDuration:kMBMapViewController_AnnotationInsertDeleteAnimationDuration delay:0. options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
					 animations:^{ annotationView.alpha = 0.; }
					 completion:^(BOOL finished) { [self removeAnnotation:annotation]; annotationView.alpha = 1.; }];
}


- (void)removeAnnotations:(NSArray<id<MKAnnotation>>*)annotations animated:(BOOL)animated
{
	if (!animated)
	{
		[self removeAnnotations:annotations];
		return;
	}
	NSMutableArray<id<MKAnnotation>> *annotationsWithView = [[NSMutableArray alloc] init], *annotationsWithoutView = [[NSMutableArray alloc] init];
	NSMutableArray<MKAnnotationView*> *annotationsViews = [[NSMutableArray alloc] init];
	for (id <MKAnnotation> annotation in annotations)
	{
		MKAnnotationView *annotationView = [self viewForAnnotation:annotation];
		if (annotationView)
		{
			[annotationsWithView addObject:annotation];
			[annotationsViews addObject:annotationView];
		}
		else
		{
			[annotationsWithoutView addObject:annotation];
		}
	}
	[self removeAnnotations:annotationsWithoutView];
	[UIView animateWithDuration:kMBMapViewController_AnnotationInsertDeleteAnimationDuration delay:0. options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
					 animations:^{ for (MKAnnotationView *annotationView in annotationsViews) annotationView.alpha = 0.; }
					 completion:^(BOOL finished) { [self removeAnnotations:annotationsWithView]; for (MKAnnotationView *annotationView in annotationsViews) annotationView.alpha = 1.; }];
}


@end

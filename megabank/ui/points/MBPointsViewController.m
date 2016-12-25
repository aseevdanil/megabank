//
//  MBPointsViewController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsViewController.h"

#import "MBPointsViewController+MBPointsPanel.h"
#import "UIAlertController+MBMPoint.h"

#import "MBPointsModel.h"

#import "MBPointsView.h"
#import "MBPointsPanel.h"



@interface MBPointsViewController () <MBPointsModelDelegate>
{
	MBPointsModel *_model;
	
	id<MBPointsAnnotation> _pointsPanelAnnotation;
	MBPointsPanel *_pointsPanel;
	unsigned int _needUpdatePointsPanel : 1;
}

@end


@implementation MBPointsViewController


#pragma mark -
#pragma mark Base


@synthesize sceneIdentifier = _sceneIdentifier;


- (instancetype)init
{
	if ((self = [super init]))
	{
		_needUpdatePointsPanel = NO;
		self.disabledMapLongPress = YES;
		self.title = LOCAL(@"Карта");
		
		NSFetchRequest *request = [MBMPoint MB_requestInContext:theApp.context];
		request.includesSubentities = NO;
		request.includesPropertyValues = YES;
		request.returnsObjectsAsFaults = NO;
		request.relationshipKeyPathsForPrefetching = [NSArray arrayWithObject:@"partner"];
		_model = [[MBPointsModel alloc] initWithPointsRequest:request andLoadFunction:kMBAPI_Points];
		_model.delegate = self;
		self.regionCenterCoordinate = _model.location;
		self.loading = !_model.isResumed;
	}
	return self;
}


- (void)pointsModelResumedDidChange:(MBPointsModel*)model
{
	self.loading = !_model.isResumed;
}


- (void)pointsModelLocationDidChange:(MBPointsModel*)model
{
	self.regionCenterCoordinate = model.location;
	if ([self isMapViewReady])
	{
		[self.mapView removeAnnotations:self.mapView.annotations animated:YES];
		[self.mapView addAnnotations:_model.pointsAnnotations];
	}
	[self dismissPointsPanel:YES];
}


- (void)pointsModel:(MBPointsModel*)model didChangePointsAnnotations:(NSArray<id<MBPointsAnnotation>>*)updatedPointsAnnotations :(NSArray<id<MBPointsAnnotation>>*)deletedPointsAnnotations :(NSArray<id<MBPointsAnnotation>>*)insertedPointsAnnotations
{
	if (updatedPointsAnnotations)
	{
		if ([self isMapViewReady])
		{
			for (id<MBPointsAnnotation> pointAnnotation in updatedPointsAnnotations)
			{
				MBPointsView *pointView = (MBPointsView*)[self.mapView viewForAnnotation:pointAnnotation];
				if (pointView)
					[pointView setMBMPoints:(NSArray<MBMPoint*>*) ((id<MBPointsAnnotation>) pointAnnotation).points];
				if (pointAnnotation == _pointsPanelAnnotation)
					[_pointsPanel reloadData];
			}
		}
	}
	if (deletedPointsAnnotations)
	{
		if ([self isMapViewReady])
			[self.mapView removeAnnotations:deletedPointsAnnotations animated:YES];
		if (_pointsPanelAnnotation && [deletedPointsAnnotations indexOfObjectIdenticalTo:_pointsPanelAnnotation] != NSNotFound)
			[self dismissPointsPanel:NO];
	}
	if (insertedPointsAnnotations)
	{
		if ([self isMapViewReady])
			[self.mapView addAnnotations:insertedPointsAnnotations];
	}
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	MBMetric metric = self.traitCollection.metric;
	CGSize pinSize = [MBPointsView preferredViewSizeForMetric:metric];
	CGFloat radiusInPixels = pinSize.width * (1. / 2.);
	self.conglomerateRadiusInPixels = radiusInPixels;
}


- (void)didUpdateConglomerateRadius:(CGFloat)conglomerateRadius
{
	_model.conglomerateRadius = conglomerateRadius;
}


#pragma mark -
#pragma mark View


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.mapView.showsUserLocation = YES;
}


- (void)viewWillClear
{
	[super viewWillClear];
	[self resetNeedsUpdatePointsPanel];
}


- (void)viewDidClear
{
	[super viewDidClear];
	_pointsPanel = nil;
}


- (void)mapViewDidReady
{
	[super mapViewDidReady];
	[self.mapView addAnnotations:_model.pointsAnnotations];
	if (_pointsPanelAnnotation)
		[self presentPointsPanel:NO];
}


- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self dismissPointsPanel:animated];
}


- (void)contentViewDidLayoutSubviews
{
	[super contentViewDidLayoutSubviews];
	[self setNeedsUpdatePointsPanel];
}


- (void)didUpdateRegionRadius:(CLLocationDistance)regionRadius
{
	[_model loadPointsInRadius:regionRadius];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation == mapView.userLocation)
		return nil;
	DASSERT([annotation conformsToProtocol:@protocol(MBPointsAnnotation)]);
	MBPointsView *pointsView = (MBPointsView*)[mapView dequeueReusableAnnotationViewWithIdentifier:[MBPointsView identifier]];
	if (!pointsView)
	{
		pointsView = [[MBPointsView alloc] initWithAnnotation:nil reuseIdentifier:[MBPointsView identifier]];
		pointsView.draggable = NO;
	}
	pointsView.annotation = annotation;
	[pointsView setMBMPoints:(NSArray<MBMPoint*>*) ((id<MBPointsAnnotation>) annotation).points];
	return pointsView;
}


- (void)mapView:(MKMapView * _Nonnull)mapView regionDidChangeAnimated:(BOOL)animated
{
	[super mapView:mapView regionDidChangeAnimated:animated];
	[self setNeedsUpdatePointsPanel];
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	[mapView deselectAnnotation:view.annotation animated:YES];
	
	id<MBPointsAnnotation> pointsAnnotation = (id<MBPointsAnnotation>) view.annotation;
	if (pointsAnnotation != mapView.userLocation)
	{
		DASSERT([pointsAnnotation conformsToProtocol:@protocol(MBPointsAnnotation)]);
		if (pointsAnnotation.points.count < 2)
		{
			MBMPoint *point = pointsAnnotation.points.count > 0 ? (MBMPoint*)[pointsAnnotation.points objectAtIndex:0] : nil;
			if (point)
			{
				UIAlertController *alert = [UIAlertController alertControllerForPoint:point];
				[self presentViewController:alert animated:YES completion:nil];
			}
		}
		else
		{
			if (!_pointsPanel)
			{
				_pointsPanelAnnotation = pointsAnnotation;
				[self presentPointsPanel:YES];
			}
		}
	}
}


@end

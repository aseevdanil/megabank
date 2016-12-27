//
//  MBRegionViewController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBRegionViewController.h"

#import "MBMapControlsView.h"



@interface MBRegionViewController ()
{
	MBMapButtonItem *_scaleUpItem, *_scaleDownItem;
	
	MBMapControlsView *_controlsView;
	
	CLLocationCoordinate2D _regionCenterCoordinate;
	CGFloat _conglomerateRadiusInPixels;
	unsigned int _selfChangeRegion : 1;
	unsigned int _regionChanged : 1;
	unsigned int _regionChanging : 1;
	unsigned int _needUpdateConglomerateRadius : 1;
	
	unsigned int _loading : 1;
}

- (void)updateConglomerateRadius;
- (void)updateRegionRadiusWithRect:(MKMapRect)rect;
- (void)setupLocationRegion:(BOOL)animated;
- (void)checkLocationRegion:(BOOL)animated;

@end


@implementation MBRegionViewController


@synthesize regionCenterCoordinate = _regionCenterCoordinate, conglomerateRadiusInPixels = _conglomerateRadiusInPixels;


- (instancetype)init
{
	if ((self = [super init]))
	{
		_loading = NO;
		
		_selfChangeRegion = _regionChanged = NO;
		_regionChanging = NO;
		_needUpdateConglomerateRadius = NO;
		_regionCenterCoordinate = kCLLocationCoordinate2DInvalid;
		_conglomerateRadiusInPixels = 0.;
		
		_scaleUpItem = [[MBMapButtonItem alloc] initWithTarget:self action:@selector(handleScaleUpItem:)];
		_scaleDownItem = [[MBMapButtonItem alloc] initWithTarget:self action:@selector(handleScaleDownItem:)];
		_scaleUpItem.hidden = YES;
		//_scaleUpItem.enabled = NO;
		_scaleDownItem.hidden = YES;
		//_scaleDownItem.enabled = NO;
	}
	return self;
}


- (void)setRegionCenterCoordinate:(CLLocationCoordinate2D)regionCenterCoordinate
{
	_regionCenterCoordinate = regionCenterCoordinate;
	_regionChanged = NO;
	_scaleUpItem.hidden = !CLLocationCoordinate2DIsValid(_regionCenterCoordinate);
	_scaleDownItem.hidden = !CLLocationCoordinate2DIsValid(_regionCenterCoordinate);
	if ([self isMapViewReady])
		[self setupLocationRegion:YES];
}


- (void)setConglomerateRadiusInPixels:(CGFloat)conglomerateRadiusInPixels
{
	if (conglomerateRadiusInPixels == _conglomerateRadiusInPixels)
		return;
	_conglomerateRadiusInPixels = conglomerateRadiusInPixels;
	if ([self isMapViewReady])
		[self setupLocationRegion:YES];
}


- (void)didUpdateConglomerateRadius:(CGFloat)conglomerateRadius
{
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.mapView.pitchEnabled = NO;
	self.mapView.rotateEnabled = NO;
	
	_controlsView = [[MBMapControlsView alloc] initWithFrame:self.contentView.bounds];
	_controlsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.contentView addSubview:_controlsView];
	_controlsView.loading = _loading;
	_controlsView.scaleUpButtonItem = _scaleUpItem;
	_controlsView.scaleDownButtonItem = _scaleDownItem;
}


- (void)viewWillClear
{
	[super viewWillClear];
	if (_needUpdateConglomerateRadius)
	{
		_needUpdateConglomerateRadius = NO;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateConglomerateRadiusTimeoutFire) object:nil];
	}
}


- (void)viewDidClear
{
	[super viewDidClear];
	_selfChangeRegion = _regionChanged = NO;
	_regionChanging = NO;
	[self didUpdateConglomerateRadius:-1.];
	_controlsView = nil;
}


- (void)anchorViewDidLayoutSubviews
{
	[super anchorViewDidLayoutSubviews];
	if ([self isMapViewReady])
	{
		if (!_regionChanged)
			[self setupLocationRegion:NO];
		else
			[self checkLocationRegion:YES];
	}
}


- (BOOL)isLoading
{
	return _loading;
}


- (void)setLoading:(BOOL)loading
{
	_loading = loading;
	if ([self isViewLoaded])
		_controlsView.loading = _loading;
}


#pragma mark Region


static const struct
{
	CLLocationDistance defaultRegionRadius, minimumRegionRadius, maximumRegionRadius;
	CLLocationDistance conglomerateRadiusStep;
}
RegionMetric[] =
{							/*regionRadius*/		/*conglomerateRadius*/
	/*MBMetricCompact*/		1000., 100., 5000.,		100.,
	/*MBMetricRegualr*/		2000., 100., 8000.,		100.,
};


- (void)handleScaleUpItem:(id)sender
{
	DASSERT(CLLocationCoordinate2DIsValid(_regionCenterCoordinate));
	if (!CLLocationCoordinate2DIsValid(_regionCenterCoordinate))
		return;
	if ([self isViewLoaded])
	{
		MKMapRect visibleRect = self.mapView.visibleMapRect;
		visibleRect.size.width /= 2;
		visibleRect.size.height /= 2;
		visibleRect.origin.x += visibleRect.size.width / 2;
		visibleRect.origin.y += visibleRect.size.height / 2;
		double minimumRadius = RegionMetric[self.traitCollection.metric].minimumRegionRadius * MKMapPointsPerMeterAtLatitude(_regionCenterCoordinate.latitude);
		if (visibleRect.size.width < 2 * minimumRadius || visibleRect.size.height < 2 * minimumRadius)
		{
			double offset = MIN(visibleRect.size.width, visibleRect.size.height) / 2 - minimumRadius;
			visibleRect.origin.x += offset;
			visibleRect.origin.y += offset;
			visibleRect.size.width -= 2 * offset;
			visibleRect.size.height -= 2 * offset;
		}
		[self.mapView setVisibleMapRect:visibleRect animated:NO];
	}
}


- (void)handleScaleDownItem:(id)sender
{
	DASSERT(CLLocationCoordinate2DIsValid(_regionCenterCoordinate));
	if (!CLLocationCoordinate2DIsValid(_regionCenterCoordinate))
		return;
	if ([self isViewLoaded])
	{
		MKMapRect visibleRect = self.mapView.visibleMapRect;
		visibleRect.origin.x -= visibleRect.size.width / 2;
		visibleRect.origin.y -= visibleRect.size.height / 2;
		visibleRect.size.width *= 2;
		visibleRect.size.height *= 2;
		double maximumRadius = RegionMetric[self.traitCollection.metric].maximumRegionRadius * MKMapPointsPerMeterAtLatitude(_regionCenterCoordinate.latitude);
		if (visibleRect.size.width > 2 * maximumRadius && visibleRect.size.height > 2 * maximumRadius)
		{
			double offset = MIN(visibleRect.size.width, visibleRect.size.height) / 2 - maximumRadius;
			visibleRect.origin.x += offset;
			visibleRect.origin.y += offset;
			visibleRect.size.width -= 2 * offset;
			visibleRect.size.height -= 2 * offset;
		}
		[self.mapView setVisibleMapRect:visibleRect animated:NO];
	}
}


- (void)updateConglomerateRadius
{
	if (_needUpdateConglomerateRadius)
	{
		_needUpdateConglomerateRadius = NO;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateConglomerateRadiusTimeoutFire) object:nil];
	}
	
	DASSERT([self isViewLoaded]);
	if (CLLocationCoordinate2DIsValid(_regionCenterCoordinate) && _conglomerateRadiusInPixels > 0.)
	{
		double angle = DADegreesToRadians(self.mapView.camera.heading);
		CGFloat offsetX = _conglomerateRadiusInPixels * cos(angle), offsetY = _conglomerateRadiusInPixels * sin(angle);
		CGPoint locationPoint = [self.mapView convertCoordinate:_regionCenterCoordinate toPointToView:self.mapView];
		CGPoint leftHalfRadiusPoint = CGPointOffset(locationPoint, CGSizeMake(-offsetX, offsetY));
		CGPoint rifgtHalfRadiusPoint = CGPointOffset(locationPoint, CGSizeMake(offsetX, -offsetY));
		CLLocationCoordinate2D leftHalfRadiusCoordinate = [self.mapView convertPoint:leftHalfRadiusPoint toCoordinateFromView:self.mapView];
		CLLocationCoordinate2D rightHalfRadiusCoordinate = [self.mapView convertPoint:rifgtHalfRadiusPoint toCoordinateFromView:self.mapView];
		MKMapPoint leftHalfRadiusMapPoint = MKMapPointForCoordinate(leftHalfRadiusCoordinate), rightHalfRadiusMapPoint = MKMapPointForCoordinate(rightHalfRadiusCoordinate);
		CLLocationDistance radius = MKMetersBetweenMapPoints(leftHalfRadiusMapPoint, rightHalfRadiusMapPoint);
		
		MBMetric metric = self.traitCollection.metric;
		double pointsPerMeter = MKMapPointsPerMeterAtLatitude(_regionCenterCoordinate.latitude);
		double minimumRadius = RegionMetric[metric].minimumRegionRadius * pointsPerMeter, maximumRadius = RegionMetric[metric].maximumRegionRadius * pointsPerMeter;
		MKMapRect minimumRect, maximumRect;
		minimumRect.origin = maximumRect.origin = MKMapPointForCoordinate(_regionCenterCoordinate);
		minimumRect.origin.x -= minimumRadius;
		minimumRect.origin.y -= minimumRadius;
		minimumRect.size.width = minimumRect.size.height = 2 * minimumRadius;
		maximumRect.origin.x -= maximumRadius;
		maximumRect.origin.y -= maximumRadius;
		maximumRect.size.width = maximumRect.size.height = 2 * maximumRadius;
		UIEdgeInsets anchorViewInsets = self.anchorInsets;
		minimumRect = [self.mapView mapRectThatFits:minimumRect edgePadding:anchorViewInsets];
		maximumRect = [self.mapView mapRectThatFits:maximumRect edgePadding:anchorViewInsets];
		MKMapRect visibleRect = self.mapView.visibleMapRect;
		double scale = 1.;
		if (visibleRect.size.width < minimumRect.size.width)
			scale = visibleRect.size.width / minimumRect.size.width;
		else if (maximumRect.size.width < visibleRect.size.width)
			scale = visibleRect.size.width / maximumRect.size.width;
		radius /= scale;
		
		radius = round(radius / RegionMetric[metric].conglomerateRadiusStep) * RegionMetric[metric].conglomerateRadiusStep;
		[self didUpdateConglomerateRadius:radius * pointsPerMeter];
	}
	else
	{
		[self didUpdateConglomerateRadius:-1.];
	}
}


- (void)_updateConglomerateRadiusTimeoutFire
{
	_needUpdateConglomerateRadius = NO;
	[self updateConglomerateRadius];
}


- (void)updateRegionRadiusWithRect:(MKMapRect)rect
{
	MKMapPoint regionCenterMapPoint = MKMapPointForCoordinate(_regionCenterCoordinate);
	MKMapPoint point = rect.origin;
	double r1 = MKDistance(regionCenterMapPoint, point);
	point.x += rect.size.width;
	double r2 = MKDistance(regionCenterMapPoint, point);
	point.y += rect.size.height;
	double r3 = MKDistance(regionCenterMapPoint, point);
	point.x -= rect.size.width;
	double r4 = MKDistance(regionCenterMapPoint, point);
	double radius = MAX(MAX(r1, r2), MAX(r3, r4));
	[self didUpdateRegionRadius:radius * MKMetersPerMapPointAtLatitude(_regionCenterCoordinate.latitude)];
}


- (void)setupLocationRegion:(BOOL)animated
{
	DASSERT([self isViewLoaded]);
	_selfChangeRegion = YES;
	MKMapRect rect = MKMapRectWorld;
	if (CLLocationCoordinate2DIsValid(_regionCenterCoordinate))
	{
		MBMetric metric = self.traitCollection.metric;
		double radius = RegionMetric[metric].defaultRegionRadius * MKMapPointsPerMeterAtLatitude(_regionCenterCoordinate.latitude);
		rect.origin = MKMapPointForCoordinate(_regionCenterCoordinate);
		rect.origin.x -= radius;
		rect.origin.y -= radius;
		rect.size.width = rect.size.height = 2 * radius;
	}
	UIEdgeInsets anchorViewInsets = self.anchorInsets;
	rect = [self.mapView mapRectThatFits:rect edgePadding:anchorViewInsets];
	MKMapRect visibleRect = self.mapView.visibleMapRect;
	if (!MKMapRectEqualToRect(rect, visibleRect))
	{
		[self.mapView setVisibleMapRect:rect edgePadding:anchorViewInsets animated:animated];
		if (_needUpdateConglomerateRadius)
		{
			_needUpdateConglomerateRadius = NO;
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateConglomerateRadiusTimeoutFire) object:nil];
		}
		[self updateConglomerateRadius];
	}
	[self updateRegionRadiusWithRect:rect];
	_selfChangeRegion = NO;
}


- (void)checkLocationRegion:(BOOL)animated
{
	DASSERT([self isViewLoaded]);
	_selfChangeRegion = YES;
	if (CLLocationCoordinate2DIsValid(_regionCenterCoordinate))
	{
		MBMetric metric = self.traitCollection.metric;
		double pointsPerMeter = MKMapPointsPerMeterAtLatitude(_regionCenterCoordinate.latitude);
		double minimumRadius = RegionMetric[metric].minimumRegionRadius * pointsPerMeter, maximumRadius = RegionMetric[metric].maximumRegionRadius * pointsPerMeter;
		MKMapPoint regionCenterMapPoint = MKMapPointForCoordinate(_regionCenterCoordinate);
		MKMapRect minimumRect, maximumRect;
		minimumRect.origin = maximumRect.origin = regionCenterMapPoint;
		minimumRect.origin.x -= minimumRadius;
		minimumRect.origin.y -= minimumRadius;
		minimumRect.size.width = minimumRect.size.height = 2 * minimumRadius;
		maximumRect.origin.x -= maximumRadius;
		maximumRect.origin.y -= maximumRadius;
		maximumRect.size.width = maximumRect.size.height = 2 * maximumRadius;
		UIEdgeInsets anchorViewInsets = self.anchorInsets;
		minimumRect = [self.mapView mapRectThatFits:minimumRect edgePadding:anchorViewInsets];
		maximumRect = [self.mapView mapRectThatFits:maximumRect edgePadding:anchorViewInsets];
		MKMapRect visibleRect = self.mapView.visibleMapRect;
		MKMapRect validVisibleRect = visibleRect;
		if (validVisibleRect.size.width < minimumRect.size.width)
		{
			double shift = (minimumRect.size.width - validVisibleRect.size.width) / 2;
			validVisibleRect.size.width = minimumRect.size.width;
			validVisibleRect.origin.x -= shift;
		}
		else if (maximumRect.size.width < validVisibleRect.size.width)
		{
			double shift = (validVisibleRect.size.width - maximumRect.size.width) / 2;
			validVisibleRect.size.width = maximumRect.size.width;
			validVisibleRect.origin.x += shift;
		}
		if (validVisibleRect.size.height < minimumRect.size.height)
		{
			double shift = (minimumRect.size.height - validVisibleRect.size.height) / 2;
			validVisibleRect.size.height = minimumRect.size.height;
			validVisibleRect.origin.y -= shift;
		}
		else if (maximumRect.size.height < validVisibleRect.size.height)
		{
			double shift = (validVisibleRect.size.height - maximumRect.size.height) / 2;
			validVisibleRect.size.height = maximumRect.size.height;
			validVisibleRect.origin.y += shift;
		}
		if (validVisibleRect.origin.x < maximumRect.origin.x)
			validVisibleRect.origin.x = maximumRect.origin.x;
		else if (maximumRect.origin.x + maximumRect.size.width < validVisibleRect.origin.x + validVisibleRect.size.width)
			validVisibleRect.origin.x = maximumRect.origin.x + maximumRect.size.width - validVisibleRect.size.width;
		if (validVisibleRect.origin.y < maximumRect.origin.y)
			validVisibleRect.origin.y = maximumRect.origin.y;
		else if (maximumRect.origin.y + maximumRect.size.height < validVisibleRect.origin.y + validVisibleRect.size.height)
			validVisibleRect.origin.y = maximumRect.origin.y + maximumRect.size.height - validVisibleRect.size.height;
		if (!MKMapRectEqualToRect(visibleRect, validVisibleRect))
		{
			[self.mapView setVisibleMapRect:validVisibleRect animated:animated];
			if (_needUpdateConglomerateRadius)
			{
				_needUpdateConglomerateRadius = NO;
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateConglomerateRadiusTimeoutFire) object:nil];
			}
			_needUpdateConglomerateRadius = YES;
			[self performSelector:@selector(_updateConglomerateRadiusTimeoutFire) withObject:nil afterDelay:0.];
		}
		[self updateRegionRadiusWithRect:validVisibleRect];
	}
	_selfChangeRegion = NO;
}


- (void)didUpdateRegionRadius:(CLLocationDistance)regionRadius
{
}


- (void)mapView:(MKMapView * _Nonnull)mapView regionWillChangeAnimated:(BOOL)animated
{
	_regionChanging = YES;
}


- (void)mapView:(MKMapView * _Nonnull)mapView regionDidChangeAnimated:(BOOL)animated
{
	_regionChanging = NO;
	
	if (!_selfChangeRegion && CLLocationCoordinate2DIsValid(_regionCenterCoordinate))
	{
		_regionChanged = YES;
		[self checkLocationRegion:YES];
		
		if (_needUpdateConglomerateRadius)
		{
			_needUpdateConglomerateRadius = NO;
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateConglomerateRadiusTimeoutFire) object:nil];
		}
		_needUpdateConglomerateRadius = YES;
		[self performSelector:@selector(_updateConglomerateRadiusTimeoutFire) withObject:nil afterDelay:0.];
	}
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
	if (_regionChanging || _selfChangeRegion)
		return;
	
	[super mapView:mapView didAddAnnotationViews:views];
}


@end

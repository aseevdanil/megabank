//
//  MBPointsController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsController.h"



@interface MBPointsAnnotation : NSObject <MBPointsAnnotation>
{
	CLLocationCoordinate2D _coordinate;
	NSMutableArray<id<MBPoint>> *_points;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSMutableArray<id<MBPoint>> *mutablePoints;
@end


@implementation MBPointsAnnotation

@synthesize coordinate = _coordinate;
@synthesize mutablePoints = _points;

- (instancetype)init
{
	if ((self = [super init]))
	{
		_coordinate = kCLLocationCoordinate2DInvalid;
		_points = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSArray<id<MBPoint>>*)points
{
	return _points;
}

@end



@interface MBPointsController ()
{
	Class __unsafe_unretained _pointsRequestClass;
	BOOL _pointsRequestIncludesSubentities;
	NSPredicate *_pointsRequestPredicate;
	
	NSMutableArray<id<MBPoint>> *_points;
	NSMutableArray<MBPointsAnnotation*> *_pointsAnnotations;
}

- (void)recalculateConglomerates;

@end


@implementation MBPointsController


@synthesize pointsRequest = _pointsRequest;
@synthesize locationCenter = _locationCenter, conglomerateRadius = _conglomerateRadius;
@synthesize changeObserver = _changeObserver;


- (instancetype)initWithPointsRequest:(NSFetchRequest*)pointsRequest
{
	DASSERT(pointsRequest);
	if ((self = [super init]))
	{
		_pointsRequest = pointsRequest;
		_pointsRequestClass = NSClassFromString(_pointsRequest.entity.name);
		_pointsRequestIncludesSubentities = _pointsRequest.includesSubentities;
		_pointsRequestPredicate = _pointsRequest.predicate;
		
		_locationCenter = kCLLocationCoordinate2DInvalid;
		_conglomerateRadius = -1.;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:theApp.context];
	}
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:theApp.context];
}


- (void)setLocationCenter:(CLLocationCoordinate2D)locationCenter
{
	_conglomerateRadius = -1.;
	_points = nil;
	_pointsAnnotations = nil;
	_locationCenter = locationCenter;
	if (CLLocationCoordinate2DIsValid(_locationCenter))
	{
		_points = [[NSMutableArray alloc] initWithCapacity:100];
		_pointsAnnotations = [[NSMutableArray alloc] initWithCapacity:100];
		
		NSArray *points = [_pointsRequest MB_requestedAllInContext:theApp.context];
		[_points setArray:points];
	}
}


- (void)setConglomerateRadius:(double)conglomerateRadius
{
	if (!CLLocationCoordinate2DIsValid(_locationCenter))
		return;
	if (conglomerateRadius < 0.)
		conglomerateRadius = -1.;
	if (conglomerateRadius == _conglomerateRadius)
		return;
	_conglomerateRadius = conglomerateRadius;
	if (conglomerateRadius >= 0.)
	{
		[self recalculateConglomerates];
	}
	else
	{
		NSArray *deletedPointsAnnotations = [_pointsAnnotations copy];
		[_pointsAnnotations removeAllObjects];
		id strongChangeObserver = _changeObserver;
		if (strongChangeObserver)
			[strongChangeObserver pointsController:self didChangePointsAnnotations:nil :deletedPointsAnnotations :nil];
	}
}


- (NSArray<id<MBPointsAnnotation>>*)pointsAnnotations
{
	return _pointsAnnotations;
}


- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification
{
	if (!_points)
		return;
	
	NSSet *deletedObjects = (NSSet*)[notification.userInfo objectForKey:NSDeletedObjectsKey];
	NSSet *insertedObjects = (NSSet*)[notification.userInfo objectForKey:NSInsertedObjectsKey];
	NSSet *updatedObjects = (NSSet*)[notification.userInfo objectForKey:NSUpdatedObjectsKey];
	
	// Здесь делаю все очень просто, поэтому не самый оптимальный вариант.
	// По хорошему, нужно отдельно хранить текущие координаты точек, и сортировать их по удаленности от _locationCenter.
	// Тогда массив _points будет отсортирован и поиск по нему будет гораздо быстрее.
	// Кроме того можно будет легко определять ситуации, когда ничего не добавляется и не убирается,
	// а изменяются лишь не ключевые параметры некоторых точек (не location) и в таких случаях не пересчитывать сетку конгломератов.
	
#define OBJECT_IS_REQUESTED_POINT(__obj) (_pointsRequestIncludesSubentities ? [__obj isKindOfClass:_pointsRequestClass] : [__obj class] == _pointsRequestClass)
#define POINT_SATISFIES_PREDICATE(__point) (!_pointsRequestPredicate || [_pointsRequestPredicate evaluateWithObject:__point])
	
	NSMutableIndexSet *removedPointsIndexes = [[NSMutableIndexSet alloc] init], *changedPointsIndexes = [[NSMutableIndexSet alloc] init];
	NSMutableArray *insertedPoints = [[NSMutableArray alloc] init];
	[deletedObjects enumerateObjectsUsingBlock:^(NSManagedObject<MBPoint> *point, BOOL *stop)
	 {
		 if (OBJECT_IS_REQUESTED_POINT(point))
		 {
			 NSUInteger pointIndex = [_points indexOfObjectIdenticalTo:point];
			 if (pointIndex != NSNotFound)
				 [removedPointsIndexes addIndex:pointIndex];
		 }
	 }];
	[insertedObjects enumerateObjectsUsingBlock:^(NSManagedObject<MBPoint> *point, BOOL *stop)
	 {
		 if (OBJECT_IS_REQUESTED_POINT(point) && POINT_SATISFIES_PREDICATE(point))
			 [insertedPoints addObject:point];
	 }];
	[updatedObjects enumerateObjectsUsingBlock:^(NSManagedObject<MBPoint> *point, BOOL *stop)
	 {
		 if (OBJECT_IS_REQUESTED_POINT(point))
		 {
			 NSUInteger pointIndex = [_points indexOfObjectIdenticalTo:point];
			 if (pointIndex != NSNotFound)
			 {
				 if (POINT_SATISFIES_PREDICATE(point))
					 [insertedPoints addObject:point];
			 }
			 else
			 {
				 if (POINT_SATISFIES_PREDICATE(point))
					 [changedPointsIndexes addIndex:pointIndex];
				 else
					 [removedPointsIndexes addIndex:pointIndex];
			 }
		 }
	 }];
	BOOL changed = NO;
	if (removedPointsIndexes.count > 0)
	{
		[_points removeObjectsAtIndexes:removedPointsIndexes];
		changed = YES;
	}
	if (insertedPoints.count > 0)
	{
		[_points addObjectsFromArray:insertedPoints];
		changed = YES;
	}
	if (changedPointsIndexes.count > 0)
	{
		changed = YES;
	}
	if (changed)
	{
		if (_conglomerateRadius >= 0.)
			[self recalculateConglomerates];
	}
	
#undef POINT_SATISFIES_PREDICATE
#undef OBJECT_IS_REQUESTED_POINT
}


#pragma mark Conglomerates calculations


// Быстрый поиск квадратного окрня из целого числа
NSUInteger isqrt(NSUInteger x)
{
	if (x < 1) return 0;
	register NSUInteger op = x, res = 0, one = 1;
	/* "one" starts at the highest power of four <= than the argument. */
	one <<= (sizeof(NSUInteger) * 8 - 2);  /* second-to-top bit set */
	while (one > op) one >>= 2;
	while (one != 0) {
		if (op >= res + one) {
			op -= res + one;
			res += one << 1;  // <-- faster than 2 * one
		}
		res >>= 1;
		one >>= 2;
	}
	return res;
}


// Разбиваю карту на концентрические колечки ширины _conglomerateRadius, расширяющиеся от _locationCenter, каждое колечко разбиваю на несколько сегментов - конгломератов.
// Все достаточно быстро, единственное слабое звено - "тяжелая" функция atan2... нужно будет на досуге подумать как избавиться от нее, чтобы свести все только к алгебраическим операциям!

NS_INLINE MKMapPoint _normalize_point(MKMapPoint center, double scale, MKMapPoint point)
{
	MKMapPoint relative_point;
	relative_point.x = (center.x - point.x) / scale;
	relative_point.y = (center.y - point.y) / scale;
	return relative_point;
}

NS_INLINE NSUInteger _conglomerate_number_for_point(MKMapPoint point)
{
	NSUInteger conglomerates_level = isqrt((NSUInteger)(point.x * point.x + point.y * point.y));
	if (conglomerates_level == 0)
		return 0;
	double alpha = atan2(point.y, point.x) + M_PI;
	double level_delta = 2 * M_PI / (2 * conglomerates_level + 1);
	NSUInteger conglomerates_number_in_previous_levels = conglomerates_level * conglomerates_level;
	NSUInteger conglomerates_number_in_current_levels = alpha < 2 * M_PI ? alpha / level_delta : 0;
	return conglomerates_number_in_previous_levels + conglomerates_number_in_current_levels;
}


- (void)recalculateConglomerates
{
	DASSERT(_conglomerateRadius >= 0.);
	NSMutableArray *deletedPointsAnnotations = [_pointsAnnotations mutableCopy];
	[_pointsAnnotations removeAllObjects];
	if (_conglomerateRadius == 0.)
	{
		for (id<MBPoint> point in _points)
		{
			CLLocationCoordinate2D pointLocation = point.location;
			if (CLLocationCoordinate2DIsValid(pointLocation))
			{
				MBPointsAnnotation *pointsAnnotation = nil;
				for (NSUInteger j = 0; j < _pointsAnnotations.count; ++j)
				{
					MBPointsAnnotation *pa = (MBPointsAnnotation*)[_pointsAnnotations objectAtIndex:j];
					if (CLLocationCoordinate2DEqualToLocationCoordinate2D(pointLocation, pa.coordinate))
					{
						pointsAnnotation = pa;
						break;
					}
				}
				if (!pointsAnnotation)
				{
					pointsAnnotation = [[MBPointsAnnotation alloc] init];
					pointsAnnotation.coordinate = pointLocation;
					[_pointsAnnotations addObject:pointsAnnotation];
				}
				[pointsAnnotation.mutablePoints addObject:point];
			}
		}
	}
	else
	{
		DASSERT(CLLocationCoordinate2DIsValid(_locationCenter));
		MKMapPoint centerMapPoint = MKMapPointForCoordinate(_locationCenter);
		NSMutableIndexSet *pointsAnnotationsConglomeratesNumbers = [[NSMutableIndexSet alloc] init]; // номера конгломератов, в которых уже есть annotation
		for (id<MBPoint> point in _points)
		{
			CLLocationCoordinate2D pointLocation = point.location;
			if (CLLocationCoordinate2DIsValid(pointLocation))
			{
				MKMapPoint pointMapPoint = MKMapPointForCoordinate(pointLocation);
				NSUInteger pointMapPointConglomerateNumber = _conglomerate_number_for_point(_normalize_point(centerMapPoint, _conglomerateRadius, pointMapPoint));
				MBPointsAnnotation *pointsAnnotation = nil;
				NSUInteger pointsAnnotationNumberLessThanOrEqualToConglomerate = [pointsAnnotationsConglomeratesNumbers indexLessThanOrEqualToIndex:pointMapPointConglomerateNumber];
				NSUInteger pointsAnnotationIndex = pointsAnnotationNumberLessThanOrEqualToConglomerate != NSNotFound ? [pointsAnnotationsConglomeratesNumbers countOfIndexesInRange:NSMakeRange(0, pointsAnnotationNumberLessThanOrEqualToConglomerate + 1)] : 0;
				if (pointsAnnotationNumberLessThanOrEqualToConglomerate == pointMapPointConglomerateNumber)
				{	// если в конгломерате уже есть annotation, то просто добавляю точку туда и центрирую координаты annotation с учетом новой точки
					pointsAnnotation = (MBPointsAnnotation*)[_pointsAnnotations objectAtIndex:pointsAnnotationIndex - 1];
					NSUInteger pointsAnnotationPointsCount = pointsAnnotation.points.count;
					CLLocationDegrees updatedPointsAnnotationLatitude = (pointsAnnotationPointsCount * pointsAnnotation.coordinate.latitude + pointLocation.latitude) / (pointsAnnotationPointsCount + 1);
					CLLocationDegrees updatedPointsAnnotationLongitude = (pointsAnnotationPointsCount * pointsAnnotation.coordinate.longitude + pointLocation.longitude) / (pointsAnnotationPointsCount + 1);
					pointsAnnotation.coordinate = CLLocationCoordinate2DMake(updatedPointsAnnotationLatitude, updatedPointsAnnotationLongitude);
				}
				else
				{	// иначе создаю новую annotation для данного конгломерата с этой точкой
					pointsAnnotation = [[MBPointsAnnotation alloc] init];
					pointsAnnotation.coordinate = pointLocation;
					[_pointsAnnotations insertObject:pointsAnnotation atIndex:pointsAnnotationIndex];
					[pointsAnnotationsConglomeratesNumbers addIndex:pointMapPointConglomerateNumber];
				}
				[pointsAnnotation.mutablePoints addObject:point];
			}
		}
	}
	NSMutableArray *updatedPointsAnnotations = [[NSMutableArray alloc] init], *insertedPointsAnnotations = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < _pointsAnnotations.count; ++i)
	{
		MBPointsAnnotation *pointsAnnotation = (MBPointsAnnotation*)[_pointsAnnotations objectAtIndex:i];
		NSUInteger index = NSNotFound;
		for (NSUInteger j = 0; j < deletedPointsAnnotations.count; ++j)
		{
			MBPointsAnnotation *pa = (MBPointsAnnotation*)[deletedPointsAnnotations objectAtIndex:j];
			if (CLLocationCoordinate2DEqualToLocationCoordinate2D(pa.coordinate, pointsAnnotation.coordinate))
			{
				index = j;
				break;
			}
		}
		if (index != NSNotFound)
		{
			MBPointsAnnotation *oldPointsAnnotation = (MBPointsAnnotation*)[deletedPointsAnnotations objectAtIndex:index];
			[oldPointsAnnotation.mutablePoints setArray:pointsAnnotation.points];
			[_pointsAnnotations replaceObjectAtIndex:i withObject:oldPointsAnnotation];
			[updatedPointsAnnotations addObject:oldPointsAnnotation];
			[deletedPointsAnnotations removeObjectAtIndex:index];
		}
		else
		{
			[insertedPointsAnnotations addObject:pointsAnnotation];
		}
	}
	id strongChangeObserver = _changeObserver;
	if (strongChangeObserver)
		[strongChangeObserver pointsController:self didChangePointsAnnotations:updatedPointsAnnotations :deletedPointsAnnotations :insertedPointsAnnotations];
}


@end

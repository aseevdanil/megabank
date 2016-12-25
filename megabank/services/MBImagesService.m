//
//  MBImagesService.m
//  megabank
//
//  Created by da on 23.12.14.
//  Copyright (c) 2014 RBC. All rights reserved.
//

#import "MBImagesService.h"

#import "MBImageCache.h"
#import "MBDownloadSession.h"

#import "MBImageOperation.h"



@implementation MBImagesService


#pragma mark Base


SINGLETON_IMPL(sharedService)


- (instancetype)init
{
	if ((self = [super init]))
	{
		_launched = NO;
		
		_queue = [[NSOperationQueue alloc] init];
		_queue.name = @"MBImagesService";
		_queue.maxConcurrentOperationCount = 1;
		
		_imageCache = [[MBImageCache alloc] initWithCache:[MBApp serviceDirectory:@"imagecache"]];
		_imageCache.maxCacheAge = 5 * DA_DAY;
		
		_downloadSession = [[MBDownloadSession alloc] initWithCache:[MBApp serviceDirectory:@"downloadcache"] downloadQueue:_queue];
		[_downloadSession start];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)launch
{
	_launched = YES;
}


- (void)stop
{
	_launched = NO;
	[_downloadSession clearCache];
	[_downloadSession.downloadQueue addOperationWithBlock:^{ [_imageCache clear:NO]; }];
}


- (BOOL)isLaunched
{
	return _launched;
}


- (void)applicationDidReceiveMemoryWarning:(NSNotification*)notification
{
	[_imageCache clear:YES];
}


- (void)applicationDidEnterBackground:(NSNotification*)notification
{
	[_imageCache clear:YES];
	__block UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^
											   {
												   if (task != UIBackgroundTaskInvalid)
												   {
													   [[UIApplication sharedApplication] endBackgroundTask:task];
													   task = UIBackgroundTaskInvalid;
												   }
											   }];
	[_downloadSession.downloadQueue addOperationWithBlock:^
	 {
		 [_imageCache clean];
		 [[NSOperationQueue mainQueue] addOperationWithBlock:^
		  {
			  if (task != UIBackgroundTaskInvalid)
			  {
				  [[UIApplication sharedApplication] endBackgroundTask:task];
				  task = UIBackgroundTaskInvalid;
			  }
		  }];
	 }];
}


#pragma mark Images


- (MBDownloadSession*)downloadSession
{
	return _downloadSession;
}


- (MBImageCache*)imageCache
{
	return _imageCache;
}


- (id<MBOperation>)queryImageWithURL:(NSURL*)imageURL metric:(MBImageMetric)imageMetric withEffect:(MBImageEffect)effect completionHandler:(void (^)(id <MBOperation> operation, UIImage *image, NSError *error))completionHandler
{
	return [MBImageOperation queryImageWithURL:imageURL metric:imageMetric effect:effect support:(id<MBImageOperationSupport>) self completionHandler:completionHandler];
}


- (id<MBOperation>)queryImageWithURL:(NSURL*)imageURL form:(MBImageForm)form metric:(MBMetric)metric withEffect:(MBImageEffect)effect completionHandler:(void (^)(id<MBOperation> operation, UIImage *image, NSError *error))completionHandler
{
	MBImageMetric imageMetric = MBImageMetricTable[form][metric];
	return [self queryImageWithURL:imageURL metric:imageMetric withEffect:effect completionHandler:completionHandler];
}


- (id<MBOperation>)queryImageWithURL:(NSURL*)imageURL size:(CGSize)size resizeScale:(UIImageResizeScale)resizeScale cropped:(BOOL)resizeCropped withEffect:(MBImageEffect)imageEffect completionHandler:(void (^)(id <MBOperation> operation, UIImage *image, NSError *error))completionHandler
{
	MBImageMetric metric = MBImageMetricNull;
	if (size.width > 0. && size.height > 0.)
		metric = MBImageMetricMake(size.width * UIScreenScale(), size.height * UIScreenScale(), UIScreenScale(), resizeScale, resizeCropped);
	return [self queryImageWithURL:imageURL metric:metric withEffect:imageEffect completionHandler:completionHandler];
}


- (id<MBOperation>)queryImageWithURL:(NSURL*)imageURL completionHandler:(void (^)(id <MBOperation> operation, UIImage *image, NSError *error))completionHandler
{
	return [self queryImageWithURL:imageURL metric:MBImageMetricNull withEffect:MBImageEffectNone completionHandler:completionHandler];
}


@end

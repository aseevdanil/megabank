//
//  MBImageOperation.m
//  megabank
//
//  Created by da on 14.04.16.
//  Copyright © 2016 megabank. All rights reserved.
//

#import "MBImageOperation.h"

#import "MBDownloadSession.h"
#import "MBImageCache.h"



@interface MBImageOperation ()
{
	NSOperationQueue *_operationQueue;
	id <MBOperation> _suboperation;
	unsigned int _cancelled : 1;
	unsigned int _completed : 1;
	unsigned int _cancelled_operationQueue : 1;
}

- (instancetype)initWithOperationQueue:(NSOperationQueue*)operationQueue;
@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;

@property (nonatomic, strong) id <MBOperation> suboperation;

@property (nonatomic, assign, getter = isCancelled_operationQueue) BOOL cancelled_operationQueue;

- (void)cancel;
- (void)complete;

@end


@implementation MBImageOperation


@synthesize operationQueue = _operationQueue;
@synthesize suboperation = _suboperation;


- (instancetype)initWithOperationQueue:(NSOperationQueue*)operationQueue
{
	if ((self = [super init]))
	{
		_operationQueue = operationQueue;
		_completed = _cancelled = NO;
		_cancelled_operationQueue = NO;
	}
	return self;
}


- (BOOL)isCompleted
{
	CHECKMAINQUEUE
	return _completed;
}


- (BOOL)isCancelled
{
	CHECKMAINQUEUE
	return _cancelled;
}


- (BOOL)isCancelled_operationQueue
{
	return _cancelled_operationQueue;
}


- (void)setCancelled_operationQueue:(BOOL)cancelled
{
	_cancelled_operationQueue = cancelled;
}


- (void)complete
{
	CHECKMAINQUEUE
	if (_cancelled || _completed)
		return;
	[self willChangeValueForKey:@"completed"];
	_completed = YES;
	[self didChangeValueForKey:@"completed"];
}


- (void)cancel
{
	CHECKMAINQUEUE
	if (_cancelled || _completed)
		return;
	[self willChangeValueForKey:@"cancelled"];
	_cancelled = YES;
	[self didChangeValueForKey:@"cancelled"];
	[_operationQueue addOperationWithBlock:^
	 {
		 if (!_cancelled_operationQueue)
		 {
			 _cancelled_operationQueue = YES;
			 if (_suboperation)
			 {
				 [_suboperation cancel];
				 _suboperation = nil;
			 }
		 }
	 }];
}


#pragma mark Query


+ (NSString*)cacheKeyForImageURL:(NSURL*)imageURL
{
	return [imageURL.absoluteString MD5Hash];
}


+ (NSString*)cacheKey:(NSString*)cacheKey withMetric:(MBImageMetric)imageMetric andEffect:(MBImageEffect)effect
{
	DASSERT(cacheKey);
	if (!cacheKey)
		return nil;
	static NSString *const ImageResizeScaleString[] = { @"none", @"fit", @"", };
	return [NSString stringWithFormat:@"%@_%hux%hux%hhu%@%@%@", cacheKey, imageMetric.width, imageMetric.height, imageMetric.scale, ImageResizeScaleString[imageMetric.resizeScale], imageMetric.cropped ? @"crop" : @"", MBImageEffectDescription(effect)];
}


+ (MBImageOperation*)queryImageWithURL:(NSURL*)imageURL metric:(MBImageMetric)metric effect:(MBImageEffect)effect
							   support:(id <MBImageOperationSupport>)support
					 completionHandler:(void (^)(id <MBOperation> operation, UIImage *image, NSError *error))completionHandler
{
	NSError *error = nil;
	DASSERT(imageURL);
	if (!imageURL)
		error = [NSError MBMegaInvalidateURLError];
	if (error)
	{
		if (completionHandler)
			completionHandler(nil, nil, [NSError MBCannotQueryImageServiceErrorWithUnderlyingError:error]);
		return nil;
	}
	
	MBDownloadSession *downloadSession = [support downloadSession];
	MBImageCache *imageCache = [support imageCache];
	
	BOOL isMetric = !MBImageMetricEqualToMetric(metric, MBImageMetricNull);
	NSString *cacheKey = [MBImageOperation cacheKeyForImageURL:imageURL];
	NSString *imageCacheKey = isMetric ? [MBImageOperation cacheKey:cacheKey withMetric:metric andEffect:MBImageEffectNone] : cacheKey;
	NSString *effectCacheKey = effect != MBImageEffectNone ? [MBImageOperation cacheKey:cacheKey withMetric:metric andEffect:effect] : nil;
	
	UIImage *image = [imageCache readImageForKey:effectCacheKey ?: imageCacheKey fromDisk:NO];
	if (image)
	{
		if (completionHandler)
			completionHandler(nil, image, nil);
		return nil;
	}
	
	NSOperationQueue *operationQueue = downloadSession ? downloadSession.downloadQueue : nil;
	if (!operationQueue)
		operationQueue = [NSOperationQueue mainQueue];
	MBImageOperation *operation = [[MBImageOperation alloc] initWithOperationQueue:operationQueue];
	[operation.operationQueue addOperationWithBlock:^
	 {
		 if (operation.isCancelled_operationQueue)
			 return;
		 
		 UIImage *effectImage = effectCacheKey ? [imageCache readImageForKey:effectCacheKey fromDisk:YES] : nil;
		 if (effectImage)
		 {
			 [[NSOperationQueue mainQueue] addOperationWithBlock:^
			  {
				  if (operation.isCancelled)
					  return;
				  [operation complete];
				  if (completionHandler)
					  completionHandler(operation, effectImage, nil);
			  }];
			 return;
		 }
		 
		 UIImage *image = [imageCache readImageForKey:imageCacheKey fromDisk:YES];
		 if (image)
		 {
			 if (effectCacheKey)
			 {
				 image = [image effectedImage:effect];
				 [imageCache storeImage:image forKey:effectCacheKey toDisk:YES];
			 }
			 [[NSOperationQueue mainQueue] addOperationWithBlock:^
			  {
				  if (operation.isCancelled)
					  return;
				  [operation complete];
				  if (completionHandler)
					  completionHandler(operation, image, nil);
			  }];
			 return;
		 }

		 void (^fileProcessing)(NSURL*, NSError*) = ^(NSURL *location, NSError *error)
		 {
			 NSData *imageData = location ? [NSData dataWithContentsOfURL:location] : nil;
			 UIImage *image = imageData ? [UIImage imageWithData:imageData scale:UIScreenScale()] : nil;
			 if (image)
			 {
				 if (isMetric)
					 image = [image metricedImage:metric];
				 [imageCache storeImage:image forKey:imageCacheKey toDisk:YES];
				 if (effectCacheKey)
				 {
					 image = [image effectedImage:effect];
					 [imageCache storeImage:image forKey:effectCacheKey toDisk:YES];
				 }
			 }
			 [[NSOperationQueue mainQueue] addOperationWithBlock:^
			  {
				  if (operation.isCancelled)
					  return;
				  [operation complete];
				  if (completionHandler)
					  completionHandler(operation, image, image ? nil : [NSError MBCannotQueryImageServiceErrorWithUnderlyingError:error ?: [NSError MBMegaDownloadFileFailureError]]);
			  }];
		 };
		 if ([imageURL isFileURL])
			 fileProcessing(imageURL, nil);
		 else if (downloadSession)
			 operation.suboperation = [downloadSession downloadFileWithURL:imageURL completionHandler:^(NSURL *location, NSError *error)
									   {
										   if (operation.isCancelled_operationQueue)
											   return;
										   operation.suboperation = nil;
										   fileProcessing(location, error);
									   }];
		 else
			 fileProcessing(nil, [NSError MBMegaFileNotFoundError]);
	 }];
	return operation;
}


@end

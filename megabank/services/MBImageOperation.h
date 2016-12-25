//
//  MBImageOperation.h
//  megabank
//
//  Created by da on 14.04.16.
//  Copyright © 2016 megabank. All rights reserved.
//


@class MBDownloadSession, MBImageCache;


@protocol MBImageOperationSupport

- (MBDownloadSession*)downloadSession;
- (MBImageCache*)imageCache;

@end


@interface MBImageOperation : NSObject <MBOperation>

+ (NSString*)cacheKeyForImageURL:(NSURL*)imageURL;
+ (NSString*)cacheKey:(NSString*)cacheKey withMetric:(MBImageMetric)imageMetric andEffect:(MBImageEffect)effect;
+ (MBImageOperation*)queryImageWithURL:(NSURL*)imageURL metric:(MBImageMetric)metric effect:(MBImageEffect)effect
							   support:(id <MBImageOperationSupport>)support
					 completionHandler:(void (^)(id <MBOperation> operation, UIImage *image, NSError *error))completionHandler;
@property (nonatomic, assign, readonly, getter = isCancelled) BOOL cancelled;
@property (nonatomic, assign, readonly, getter = isCompleted) BOOL completed;

@end

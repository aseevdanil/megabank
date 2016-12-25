//
//  MBImagesService.h
//  megabank
//
//  Created by da on 23.12.14.
//  Copyright (c) 2014 RBC. All rights reserved.
//


@class MBDownloadSession, MBImageCache;



@interface MBImagesService : NSObject <MBService>
{
	NSOperationQueue *_queue;
	MBDownloadSession *_downloadSession;
	MBImageCache *_imageCache;
	unsigned int _launched : 1;
}

SINGLETON_DECL(sharedService)

// Все картинки запрашиваются с main queue, completionHandler тоже на main queue
- (id<MBOperation>)queryImageWithURL:(NSURL*)imageURL form:(MBImageForm)form metric:(MBMetric)metric withEffect:(MBImageEffect)effect completionHandler:(void (^)(id<MBOperation> operation, UIImage *image, NSError *error))completionHandler;
- (id<MBOperation>)queryImageWithURL:(NSURL*)imageURL size:(CGSize)size resizeScale:(UIImageResizeScale)resizeScale cropped:(BOOL)resizeCropped withEffect:(MBImageEffect)imageEffect completionHandler:(void (^)(id <MBOperation> operation, UIImage *image, NSError *error))completionHandler;
- (id<MBOperation>)queryImageWithURL:(NSURL*)imageURL completionHandler:(void (^)(id <MBOperation> operation, UIImage *image, NSError *error))completionHandler;

@end

//
//  MBDownloadSession.h
//  megabank
//
//  Created by da on 13.04.16.
//  Copyright © 2016 megabank. All rights reserved.
//



@interface MBDownloadSession : NSObject
{
	NSString *_cachePath;
	NSURLCache *_cache;
	NSOperationQueue *_downloadQueue;
	NSURLSession *_session;
	NSMutableArray *_tasks;
	unsigned int _started : 1;
	unsigned int _sessionTimeout : 1;
}

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCache:(NSString*)cachePath downloadQueue:(NSOperationQueue*)downloadQueue;
@property (nonatomic, copy, readonly) NSString *cachePath;
@property (nonatomic, strong, readonly) NSOperationQueue *downloadQueue;

@property (nonatomic, assign, readonly, getter = isStarted) BOOL started;
- (void)start;
- (void)cancel;
- (void)clearCache;

- (id<MBOperation>)downloadFileWithURL:(NSURL*)fileURL completionHandler:(void (^)(NSURL *location, NSError *error))completionHandler;	// completionHandler called on downloadQueue

@end

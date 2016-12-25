//
//  MBDownloadSession.m
//  megabank
//
//  Created by da on 13.04.16.
//  Copyright © 2016 megabank. All rights reserved.
//

#import "MBDownloadSession.h"

#import "MBDownloadSession+MBDownloadOperation.h"



@interface MBDownloadSession () <NSURLSessionDelegate>

+ (void)operation:(NSOperationQueue*)operationQueue delay:(NSTimeInterval)operationDelay block:(void (^)(void))operationBlock;

- (void)_startSession:(BOOL)resumeLostTasks;
- (void)_cancelSession;

@end


@implementation MBDownloadSession


#pragma mark -
#pragma mark Base


+ (void)operation:(NSOperationQueue*)operationQueue delay:(NSTimeInterval)operationDelay block:(void (^)(void))operationBlock
{
	if (!operationQueue)
		operationQueue = [NSOperationQueue mainQueue];
	if (operationDelay > 0.)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(operationDelay * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [operationQueue addOperationWithBlock:operationBlock]; });
	else
		[operationQueue addOperationWithBlock:operationBlock];
}


@synthesize cachePath = _cachePath, downloadQueue = _downloadQueue;


- (instancetype)initWithCache:(NSString*)cachePath downloadQueue:(NSOperationQueue*)downloadQueue
{
	if ((self = [super init]))
	{
		_started = _sessionTimeout = NO;
		_cachePath = [cachePath copy];
		_downloadQueue = downloadQueue;
		_cache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:10 * 1024 * 1024 diskPath:_cachePath];
		_tasks = [[NSMutableArray alloc] initWithCapacity:50];
	}
	return self;
}


- (void)dealloc
{
	[self deallocAllTasks];
}


- (BOOL)isStarted
{
	return _started;
}


- (void)start
{
	if (!_started)
	{
		_started = YES;
		[MBDownloadSession operation:_downloadQueue delay:0. block:^{ [self _startSession:NO]; }];
	}
}


- (void)cancel
{
	if (_started)
	{
		_started = NO;
		[MBDownloadSession operation:_downloadQueue delay:0. block:^{ [self _cancelSession]; }];
	}
}


- (void)clearCache
{
	[MBDownloadSession operation:_downloadQueue delay:0. block:^{ [_cache removeAllCachedResponses]; }];
}


- (void)_startSession:(BOOL)resumeLostTasks
{
	if (_session)
		return;
	
	_sessionTimeout = NO;
	
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	configuration.timeoutIntervalForRequest = kMBNetworkDownloadRequestTimeout;
	configuration.URLCache = _cache;
	configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
	configuration.URLCredentialStorage = nil;
	configuration.HTTPMaximumConnectionsPerHost = 4;
	_session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_downloadQueue];
	DASSERT(_session);
	if (!_session)
	{
		_sessionTimeout = YES;
		typeof(self) __weak weakSelf = self;
		[MBDownloadSession operation:_downloadQueue delay:1. block:^
		 {
			 typeof(self) strongSelf = weakSelf;
			 if (strongSelf)
			 {
				 if (strongSelf->_sessionTimeout)
					 [strongSelf _startSession:resumeLostTasks];
			 }
		 }];
		return;
	}
	
	[self resumeAllTasks];
}


- (void)_cancelSession
{
	[self cancelAllTasks];
	_sessionTimeout = NO;
	if (_session)
	{
		[_session invalidateAndCancel];
		_session = nil;
	}
}


- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
	if (!error)
		return;
	
	DASSERT(session == _session);
	_session = nil;
	
	DASSERT(!_sessionTimeout);
	_sessionTimeout = YES;
	typeof(self) __weak weakSelf = self;
	[MBDownloadSession operation:_downloadQueue delay:1. block:^
	 {
		 typeof(self) strongSelf = weakSelf;
		 if (strongSelf)
		 {
			 if (strongSelf->_sessionTimeout)
				 [strongSelf _startSession:NO];
		 }
	 }];
	
	[self suspendAllTasks];
}


#pragma mark -
#pragma mark Downloads


- (id<MBOperation>)downloadFileWithURL:(NSURL*)fileURL completionHandler:(void (^)(NSURL *location, NSError *error))completionHandler
{
	DASSERT(fileURL);
	if (!fileURL)
		return nil;
	
	DASSERT(_started);
	if (!_started)
		return nil;
	
	MBDownloadOperation *operation = [[MBDownloadOperation alloc] initWithQueue:_downloadQueue completion:completionHandler];
	[MBDownloadSession operation:_downloadQueue delay:0. block:^
	 {
		 if (operation.isCompleted)
		 	 return;
		 
		[self startOperation:operation withFileURL:fileURL];
	 }];
	return operation;
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error
{
	if (error && ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled))
		return;
	
	NSError *serverError = nil;
	NSInteger statusCode = sessionTask.response ? ((NSHTTPURLResponse*) sessionTask.response).statusCode : 0;
	if (statusCode != 0 && !(200 <= statusCode && statusCode < 300))
		serverError = [NSError MBMegaInvalidHTTPResponseErrorWithStatusCode:statusCode];
	
	if (!error && !serverError)
		return;
	
	BOOL redownload = NO;
	if (!serverError && error)
	{
		redownload = [error.domain isEqualToString:NSURLErrorDomain] && error.code != NSURLErrorUnsupportedURL;
	}
	
	NSUInteger index = [_tasks indexOfMBDownloadTaskWithSessionTask:sessionTask];
	if (index == NSNotFound)
		return;
	MBDownloadTask *task = (MBDownloadTask*)[_tasks objectAtIndex:index];
	DASSERT(task.operations.count > 0);
	if (redownload)
	{
		[self suspendTask:task];
		if (_session)
		{
			task.sessionTaskTimeout = YES;
			typeof(self) __weak weakSelf = self;
			[MBDownloadSession operation:_downloadQueue delay:kMBNetworkRequestRepeatDelay block:^
			 {
				 typeof(self) strongSelf = weakSelf;
				 if (strongSelf)
				 {
					 if (task.isSessionTaskTimeout)
						 [strongSelf resumeTask:task];
				 }
			 }];
		}
	}
	else
	{
		NSMutableArray *completionHandlers = [[NSMutableArray alloc] initWithCapacity:task.operations.count];
		for (MBDownloadOperation *operation in task.operations)
		{
			DASSERT(!operation.isCompleted);
			if (!operation.isCompleted && operation.completionHandler)
				[completionHandlers addObject:operation.completionHandler];
		}
		[_tasks removeObjectAtIndex:index];
		[self cancelTask:task];
		NSError *downloadError = error ?: (serverError ?: [NSError MBMegaUnknownError]);
		for (void (^completionHandler)(NSURL*, NSError*) in completionHandlers)
			completionHandler(nil, downloadError);
	}
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)sessionTask didFinishDownloadingToURL:(NSURL *)location
{
	if (location)
	{
		NSHTTPURLResponse *response = (NSHTTPURLResponse*) sessionTask.response;
		NSString *lastModified = (NSString*)[response.allHeaderFields objectForKey:@"Last-Modified"];
		if (lastModified)
		{
			NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:sessionTask.response data:[NSData dataWithContentsOfURL:location]];
			[_session.configuration.URLCache storeCachedResponse:cachedResponse forRequest:sessionTask.originalRequest];
		}
	}
	
	NSUInteger index = [_tasks indexOfMBDownloadTaskWithSessionTask:sessionTask];
	if (index == NSNotFound)
		return;
	MBDownloadTask *task = (MBDownloadTask*)[_tasks objectAtIndex:index];
	DASSERT(task.operations.count > 0);
	NSMutableArray *completionHandlers = [[NSMutableArray alloc] initWithCapacity:task.operations.count];
	for (MBDownloadOperation *operation in task.operations)
	{
		DASSERT(!operation.isCompleted);
		if (!operation.isCompleted && operation.completionHandler)
			[completionHandlers addObject:operation.completionHandler];
	}
	[_tasks removeObjectAtIndex:index];
	[self cancelTask:task];
	for (void (^completionHandler)(NSURL*, NSError*) in completionHandlers)
		completionHandler(location, nil);
}


@end

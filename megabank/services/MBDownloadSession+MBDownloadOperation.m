//
//  MBDownloadSession+MBDownloadOperation.m
//  megabank
//
//  Created by da on 13.04.16.
//  Copyright © 2016 megabank. All rights reserved.
//

#import "MBDownloadSession+MBDownloadOperation.h"



#pragma mark -
#pragma mark MBDownloadOperation


@implementation MBDownloadOperation


@synthesize queue = _queue, completionHandler = _completionHandler;


- (instancetype)initWithQueue:(NSOperationQueue*)queue completion:(void(^)(NSURL *location, NSError *error))completionHandler
{
	if ((self = [super init]))
	{
		_queue = queue;
		_completionHandler = [completionHandler copy];
		_completed = NO;
	}
	return self;
}


- (BOOL)isCompleted
{
	return _completed;
}


- (void)setCompleted:(BOOL)completed
{
	_completed = completed;
}


- (void)cancel
{
	[_queue addOperationWithBlock:^
	 {
		 if (!_completed)
		 {
			 [self willChangeValueForKey:@"cancelled"];
			 [self didChangeValueForKey:@"cancelled"];
		 }
	 }];
}


@end



#pragma mark -
#pragma mark MBDownloadTask


@implementation MBDownloadTask


@synthesize fileURL = _fileURL;
@synthesize sessionTask = _sessionTask;
@synthesize operations = _operations;


- (instancetype)initWithFileURL:(NSURL*)fileURL
{
	if ((self = [super init]))
	{
		_fileURL = fileURL;
		_sessionTaskTimeout = NO;
		_operations = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}


- (BOOL)isSessionTaskTimeout
{
	return _sessionTaskTimeout;
}


- (void)setSessionTaskTimeout:(BOOL)sessionTaskTimeout
{
	_sessionTaskTimeout = sessionTaskTimeout;
}


@end



@implementation NSArray (MBDownloadTask)


- (NSUInteger)indexOfMBDownloadTaskWithFileURL:(NSURL*)fileURL
{
	DASSERT(fileURL);
	for (NSUInteger i = 0; i < self.count; ++i)
	{
		MBDownloadTask *task = (MBDownloadTask*)[self objectAtIndex:i];
		if ([fileURL isEqual:task.fileURL])
			return i;
	}
	return NSNotFound;
}


- (NSUInteger)indexOfMBDownloadTaskWithSessionTask:(NSURLSessionTask*)sessionTask
{
	DASSERT(sessionTask);
	for (NSUInteger i = 0; i < self.count; ++i)
	{
		MBDownloadTask *task = (MBDownloadTask*)[self objectAtIndex:i];
		if (sessionTask == task.sessionTask)
			return i;
	}
	return NSNotFound;
}


@end



#pragma mark -


@interface MBDownloadSession (Private)

+ (void)operation:(NSOperationQueue*)operationQueue delay:(NSTimeInterval)operationDelay block:(void (^)(void))operationBlock;

@end


@implementation MBDownloadSession (MBDownloadOperation)


static char MBDownloadSessionContext;


- (void)resumeNextTask
{
	DASSERT(_session);
	if (!_session)
		return;
	
	MBDownloadTask *task = nil;
	for (MBDownloadTask *t in _tasks)
	{
		if (!t.sessionTask && !t.isSessionTaskTimeout)
		{
			task = t;
			break;
		}
	}
	if (!task)
		return;
	
	DASSERT(task.operations.count > 0);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:task.fileURL];
	NSCachedURLResponse *cachedRequest = [_session.configuration.URLCache cachedResponseForRequest:request];
	if (cachedRequest)
	{
		NSHTTPURLResponse *cachedResponse = (NSHTTPURLResponse*) cachedRequest.response;
		NSString *lastModified = (NSString*)[cachedResponse.allHeaderFields objectForKey:@"Last-Modified"];
		if (lastModified)
			[request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
	}
	NSURLSessionDownloadTask *sessionTask = [_session downloadTaskWithRequest:request];
	task.sessionTask = sessionTask;
	[sessionTask resume];
}


- (void)resumeTask:(MBDownloadTask*)task
{
	DASSERT(_session);
	if (!_session)
		return;
	
	DASSERT(task && task.operations.count > 0);
	if (task.sessionTask)
		return;
	task.sessionTaskTimeout = NO;
	
	[self resumeNextTask];
}


- (void)resumeAllTasks
{
	for (MBDownloadTask *task in _tasks)
		[self resumeTask:task];
}


- (void)suspendTask:(MBDownloadTask*)task
{
	DASSERT(task);
	if (task.sessionTask)
	{
		[task.sessionTask cancel];
		task.sessionTask = nil;
	}
	task.sessionTaskTimeout = NO;
}


- (void)suspendAllTasks
{
	for (MBDownloadTask *task in _tasks)
		[self suspendTask:task];
}


- (void)cancelTask:(MBDownloadTask*)task
{
	DASSERT(task);
	[self suspendTask:task];
	for (MBDownloadOperation *operation in task.operations)
	{
		DASSERT(!operation.isCompleted);
		operation.completed = YES;
		[operation removeObserver:self forKeyPath:@"cancelled" context:&MBDownloadSessionContext];
	}
	[task.operations removeAllObjects];
}


- (void)cancelAllTasks
{
	NSArray *downloadTasks = [_tasks copy];
	[_tasks removeAllObjects];
	for (MBDownloadTask *task in downloadTasks)
		[self cancelTask:task];
}


- (void)deallocAllTasks
{
	for (MBDownloadTask *task in _tasks)
	{
		for (MBDownloadOperation *operation in task.operations)
		{
			[operation removeObserver:self forKeyPath:@"cancelled" context:&MBDownloadSessionContext];
		}
	}
}


- (void)startOperation:(MBDownloadOperation*)operation withFileURL:(NSURL*)fileURL
{
	DASSERT(operation && !operation.isCompleted);
	if (operation.isCompleted)
		return;
	
	MBDownloadTask *downloadTask = nil;
	NSUInteger index = [_tasks indexOfMBDownloadTaskWithFileURL:fileURL];
	if (index != NSNotFound)
	{
		downloadTask = (MBDownloadTask*)[_tasks objectAtIndex:index];
	}
	else
	{
		downloadTask = [[MBDownloadTask alloc] initWithFileURL:fileURL];
		[_tasks addObject:downloadTask];
	}
	DASSERT([downloadTask.operations indexOfObjectIdenticalTo:operation] == NSNotFound);
	[downloadTask.operations addObject:operation];
	[operation addObserver:self forKeyPath:@"cancelled" options:0 context:&MBDownloadSessionContext];
	
	if (_session)
		[self resumeTask:downloadTask];
}


- (void)stopOperation:(MBDownloadOperation*)operation
{
	DASSERT(operation);
	
	NSUInteger operationIndex = NSNotFound, taskIndex = NSNotFound;
	for (NSUInteger i = 0; i < _tasks.count; ++i)
	{
		MBDownloadTask *task = (MBDownloadTask*)[_tasks objectAtIndex:i];
		operationIndex = [task.operations indexOfObjectIdenticalTo:operation];
		if (operationIndex != NSNotFound)
		{
			taskIndex = i;
			break;
		}
	}
	if (taskIndex != NSNotFound)
	{
		MBDownloadTask *task = (MBDownloadTask*)[_tasks objectAtIndex:taskIndex];
		DASSERT(operationIndex != NSNotFound);
		[task.operations removeObjectAtIndex:operationIndex];
		operation.completed = YES;
		[operation removeObserver:self forKeyPath:@"cancelled" context:&MBDownloadSessionContext];
		if (task.operations.count == 0)
		{
			[_tasks removeObjectAtIndex:taskIndex];
			[self suspendTask:task];
		}
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == &MBDownloadSessionContext)
	{
		DASSERT([object class] == [MBDownloadOperation class]);
		MBDownloadOperation *operation = (MBDownloadOperation*) object;
		if ([keyPath isEqualToString:@"cancelled"])
		{
			CHECKQUEUE(_downloadQueue)
			[self stopOperation:operation];
		}
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


@end

//
//  MBConnectService+MBConnectOperation.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBConnectService+MBConnectOperation.h"



@implementation MBConnectOperation


@synthesize queue = _queue, request = _request, options = _options, completionHandler = _completionHandler;
@synthesize task = _task, taskBackground = _taskBackground;
@synthesize receivedDataStream = _receivedDataStream;
@synthesize userInfo = _userInfo;


- (instancetype)initWithQueue:(NSOperationQueue*)queue request:(NSURLRequest*)request options:(MBConnectOptions)options completionHandler:(MBConnectCompletion)completionHandler
{
	DASSERT(request);
	if ((self = [super init]))
	{
		_queue = queue;
		_request = request;
		_options = options;
		_completionHandler = [completionHandler copy];
		
		_cancelled = _queue_cancelled = NO;
		_taskBackground = UIBackgroundTaskInvalid;
		_taskTimeout = NO;
	}
	return self;
}


- (void)cancel
{
	if (_cancelled)
		return;
	
	[self willChangeValueForKey:@"cancelled"];
	_cancelled = YES;
	[self didChangeValueForKey:@"cancelled"];
	
	[_queue addOperationWithBlock:^
	 {
		 [self willChangeValueForKey:@"queue_cancelled"];
		 _queue_cancelled = YES;
		 [self didChangeValueForKey:@"queue_cancelled"];
	 }];
}


- (BOOL)isCancelled
{
	return _cancelled;
}


- (BOOL)queue_isCancelled
{
	CHECKQUEUE(_queue)
	return _queue_cancelled;
}


- (BOOL)taskTimeout
{
	return _taskTimeout;
}


- (void)setTaskTimeout:(BOOL)taskTimeout
{
	_taskTimeout = taskTimeout;
}


@end


@implementation MBConnectOperation (MB)


- (BOOL)isPermanent
{
	return IS_FLAG(self.options, MBConnectOptionPermanently);
}


- (void)callCompletionWithResponse:(id)response error:(NSError*)error
{
	CHECKQUEUE(_queue);
	if (self.queue_isCancelled)
		return;
	if (self.completionHandler)
	{
		if (IS_FLAG(self.options, MBConnectOptionCompletionOnMainQueue))
			[[NSOperationQueue mainQueue] addOperationWithBlock:^
			 {
				 if (!self.isCancelled)
					 self.completionHandler(self, response, error);
			 }];
		else
			self.completionHandler(self, response, error);
	}
}


@end


@implementation NSArray (MBConnectOperation)


- (NSUInteger)indexOfMBConnectOperationWithTask:(NSURLSessionDataTask*)task
{
	for (NSUInteger i = 0; i < self.count; ++i)
	{
		MBConnectOperation *operation = (MBConnectOperation*)[self objectAtIndex:i];
		if (task == operation.task)
			return i;
	}
	return NSNotFound;
}


@end



#pragma mark -


@implementation MBConnectService (MBConnectOperation)


#pragma mark Operations management


- (void)startOperation:(MBConnectOperation*)operation
{
	DASSERT(operation && !operation.queue_isCancelled);
	
	DASSERT(_session);
	
	operation.taskTimeout = NO;
	
	if (operation.task)
		return;
	
	operation.task = [_session dataTaskWithRequest:operation.request];
	DASSERT(operation.taskBackground == UIBackgroundTaskInvalid);
	if (operation.isPermanent)
	{
		operation.taskBackground = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ [operation.queue addOperationWithBlock:^
			{
			   DASSERT(operation.taskBackground != UIBackgroundTaskInvalid);
			   if (operation.taskBackground != UIBackgroundTaskInvalid)
			   {
				   [[UIApplication sharedApplication] endBackgroundTask:operation.taskBackground];
				   operation.taskBackground = UIBackgroundTaskInvalid;
			   }
			}]; }];
	}
	DASSERT(!operation.receivedDataStream);
	operation.receivedDataStream = [NSOutputStream outputStreamToMemory];
	[operation.receivedDataStream open];
	[operation.task resume];
}


- (void)startAllOperations
{
	for (MBConnectOperation *operation in _operations)
		[self startOperation:operation];
}


- (void)suspendOperation:(MBConnectOperation*)operation
{
	DASSERT(operation && !operation.queue_isCancelled);
	
	operation.taskTimeout = NO;
	if (!operation.isPermanent)
	{
		if (operation.task)
		{
			[operation.task cancel];
			operation.task = nil;
		}
		if (operation.receivedDataStream)
		{
			[operation.receivedDataStream close];
			operation.receivedDataStream = nil;
		}
		DASSERT(operation.taskBackground == UIBackgroundTaskInvalid);
		if (operation.taskBackground != UIBackgroundTaskInvalid)
		{
			[[UIApplication sharedApplication] endBackgroundTask:operation.taskBackground];
			operation.taskBackground = UIBackgroundTaskInvalid;
		}
	}
}


- (void)suspendAllOperations
{
	for (MBConnectOperation *operation in _operations)
		[self suspendOperation:operation];
}


- (void)stopOperation:(MBConnectOperation*)operation
{
	DASSERT(operation);
	operation.taskTimeout = NO;
	if (operation.task)
	{
		[operation.task cancel];
		operation.task = nil;
	}
	if (operation.receivedDataStream)
	{
		[operation.receivedDataStream close];
		operation.receivedDataStream = nil;
	}
	if (operation.taskBackground != UIBackgroundTaskInvalid)
	{
		[[UIApplication sharedApplication] endBackgroundTask:operation.taskBackground];
		operation.taskBackground = UIBackgroundTaskInvalid;
	}
}


- (void)stopAllOperations
{
	for (MBConnectOperation *operation in _operations)
		[self stopOperation:operation];
}


#pragma mark Operations scheduling


static char MBConnectServiceContext;


- (void)scheduleOperation:(MBConnectOperation*)operation
{
	CHECKQUEUE(_queue)
	DASSERT(operation);
	if (operation.queue_isCancelled)
		return;
	
	[_operations addObject:operation];
	[operation addObserver:self forKeyPath:@"queue_cancelled" options:0 context:&MBConnectServiceContext];
	if (_session)
		[self startOperation:operation];
}


- (void)unscheduleOperation:(MBConnectOperation*)operation
{
	CHECKQUEUE(_queue)
	DASSERT(operation);
	NSUInteger operationIndex = [_operations indexOfObjectIdenticalTo:operation];
	DASSERT(operationIndex != NSNotFound);
	if (operationIndex != NSNotFound)
	{
		[_operations removeObjectAtIndex:operationIndex];
		[operation removeObserver:self forKeyPath:@"queue_cancelled" context:&MBConnectServiceContext];
		[self stopOperation:operation];
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == &MBConnectServiceContext)
	{
		CHECKQUEUE(_queue)
		DASSERT([object class] == [MBConnectOperation class]);
		MBConnectOperation *operation = (MBConnectOperation*) object;
		if ([keyPath isEqualToString:@"queue_cancelled"])
		{
			DASSERT(operation.queue_isCancelled);
			if (operation.queue_isCancelled)
				[self unscheduleOperation:operation];
		}
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


- (void)resetAllOperations
{
	CHECKQUEUE(_queue)
	NSArray *operations = [_operations copy];
	[_operations removeAllObjects];
	for (MBConnectOperation *operation in operations)
	{
		[operation removeObserver:self forKeyPath:@"queue_cancelled" context:&MBConnectServiceContext];
		[self stopOperation:operation];
		[operation callCompletionWithResponse:nil error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil]];
	}
}


@end

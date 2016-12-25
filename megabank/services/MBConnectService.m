//
//  MBConnectService.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBConnectService.h"

#import "MBConnectService+MBConnectOperation.h"



typedef NS_ENUM(NSUInteger, MBConnectReachabilityStatus)
{
	MBConnectReachabilityStatusUnk,
	MBConnectReachabilityStatusNotReachable,
	MBConnectReachabilityStatusReachableViaWWAN,
	MBConnectReachabilityStatusReachableViaWiFi,
};
NS_INLINE BOOL MBConnectReachabilityIsReachable(MBConnectReachabilityStatus status)
{
	return status == MBConnectReachabilityStatusReachableViaWWAN || status == MBConnectReachabilityStatusReachableViaWiFi;
}

NS_INLINE MBConnectReachabilityStatus MBConnectReachabilityStatusForFlags(SCNetworkReachabilityFlags flags)
{
	BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
	BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
	BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
	BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
	BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
	
	MBConnectReachabilityStatus status = MBConnectReachabilityStatusNotReachable;
	if (isNetworkReachable)
		status = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0 ? MBConnectReachabilityStatusReachableViaWWAN : MBConnectReachabilityStatusReachableViaWiFi;
	return status;
}



@interface MBConnectService () <NSURLSessionDelegate>
{
	SCNetworkReachabilityRef _reachability;
	id<NSObject> _applicationDidBecomeActiveNotificationToken, _applicationWillResignActiveNotificationToken;
}

- (void)updateSessionActive:(BOOL)active;

- (void)startMonitoringNetworkReachability;
- (void)stopMonitoringNetworkReachability;

- (void)startSession;
- (void)suspendSession;
- (void)resetSession;

@end


@implementation MBConnectService


#pragma mark -
#pragma mark Base


SINGLETON_IMPL(sharedService)


+ (void)operation:(NSOperationQueue*)operationQueue delay:(NSTimeInterval)operationDelay block:(void (^)(void))operationBlock
{
	if (!operationQueue)
		operationQueue = [NSOperationQueue mainQueue];
	if (operationDelay > 0.)
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(operationDelay * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [operationQueue addOperationWithBlock:operationBlock]; });
	else
		[operationQueue addOperationWithBlock:operationBlock];
}


- (instancetype)init
{
	if ((self = [super init]))
	{
		_launched = _active = NO;
		_sessionLaunched = _sessionActive = _sessionTimeout = NO;
		_reachabilityStatus = MBConnectReachabilityStatusUnk;

		_operations = [[NSMutableArray alloc] init];
		_queue = [[NSOperationQueue alloc] init];
		_queue.name = @"MBConnectService";
		_queue.maxConcurrentOperationCount = 1;
		
		[self startMonitoringNetworkReachability];
		
		typeof(self) __weak weakSelf = self;
		_applicationDidBecomeActiveNotificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:_queue usingBlock:^(NSNotification *notification)
														{
															typeof(self) strongSelf = weakSelf;
															if (strongSelf)
															{
																if (strongSelf->_sessionLaunched)
																	[strongSelf updateSessionActive:MBConnectReachabilityIsReachable(strongSelf->_reachabilityStatus)];
															}
														}];
		_applicationWillResignActiveNotificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:_queue usingBlock:^(NSNotification *notification)
														 {
															 typeof(self) strongSelf = weakSelf;
															 if (strongSelf)
															 {
																 if (strongSelf->_sessionLaunched)
																	 [strongSelf updateSessionActive:NO];
															 }
														 }];
	}
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:_applicationDidBecomeActiveNotificationToken];
	[[NSNotificationCenter defaultCenter] removeObserver:_applicationWillResignActiveNotificationToken];
	[self stopMonitoringNetworkReachability];
	[MBConnectService operation:_queue delay:0. block:^{ [self resetSession]; }];
	[_queue waitUntilAllOperationsAreFinished];
}


- (void)launch
{
	if (_launched)
		return;
	_launched = YES;
	[MBConnectService operation:_queue delay:0. block:^
	 {
		 _sessionLaunched = YES;
		 [self updateSessionActive:MBConnectReachabilityIsReachable(_reachabilityStatus) && [UIApplication sharedApplication].applicationState == UIApplicationStateActive];
	 }];
}


- (void)stop
{
	if (!_launched)
		return;
	_launched = NO;
	[MBConnectService operation:_queue delay:0. block:^
	 {
		 _sessionLaunched = NO;
		 [self updateSessionActive:NO];
	 }];
}


- (BOOL)isLaunched
{
	return _launched;
}


- (BOOL)isActive
{
	return _active;
}


- (void)updateSessionActive:(BOOL)active
{
	CHECKQUEUE(_queue)
	if (active != _sessionActive)
	{
		_sessionActive = active;
		if (_sessionActive)
		{
			[self startSession];
		}
		else
		{
			_sessionLaunched ? [self suspendSession] : [self resetSession];
		}
		[MBConnectService operation:nil delay:0. block:^
		 {
			 _active = active;
			 [[NSNotificationCenter defaultCenter] postNotificationName:MBConnectServiceDidChangeActiveNotification object:nil userInfo:nil];
		 }];
	}
}


void MBConnectService_ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
	MBConnectService *service = (__bridge MBConnectService*) info;
	[MBConnectService operation:service->_queue delay:0. block:^
	 {
		 service->_reachabilityStatus = MBConnectReachabilityStatusForFlags(flags);
		 if (service->_sessionLaunched)
			 [service updateSessionActive:MBConnectReachabilityIsReachable(service->_reachabilityStatus) && [UIApplication sharedApplication].applicationState == UIApplicationStateActive];
	 }];
}


- (void)startMonitoringNetworkReachability
{
	DASSERT(!_reachability);
	[self stopMonitoringNetworkReachability];
	
	_reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [NSURL MBAPIURL].host.UTF8String);
	DASSERT(_reachability);
	SCNetworkReachabilityContext context = {0, (__bridge void*) self, NULL, NULL, NULL};
	SCNetworkReachabilitySetCallback(_reachability, MBConnectService_ReachabilityCallback, &context);
	SCNetworkReachabilitySetDispatchQueue(_reachability, dispatch_get_main_queue());
}


- (void)stopMonitoringNetworkReachability
{
	if (_reachability)
	{
		SCNetworkReachabilitySetCallback(_reachability, NULL, NULL);
		SCNetworkReachabilitySetDispatchQueue(_reachability, NULL);
		CFRelease(_reachability);
		_reachability = nil;
	}
}


#pragma mark -
#pragma mark Session


- (void)startSession
{
	CHECKQUEUE(_queue)
	
	DASSERT(_sessionActive);
	if (!_sessionActive)
		return;
	
	if (!_session)
	{
		_sessionTimeout = NO;
		
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		configuration.timeoutIntervalForRequest = 0.;
		configuration.timeoutIntervalForResource = 0.;
		configuration.URLCache = nil;
		configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
		configuration.URLCredentialStorage = nil;
		configuration.HTTPMaximumConnectionsPerHost = 4;
		_session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_queue];
	}
	DASSERT(_session);
	if (!_session)
	{
		_sessionTimeout = YES;
		typeof(self) __weak weakSelf = self;
		[MBConnectService operation:_queue delay:1. block:^
		 {
			 typeof(self) strongSelf = weakSelf;
			 if (strongSelf)
			 {
				 if (strongSelf->_sessionTimeout)
					 [strongSelf startSession];
			 }
		 }];
		return;
	}
	
	[self startAllOperations];
}


- (void)suspendSession
{
	CHECKQUEUE(_queue)
	
	[self suspendAllOperations];
	_sessionTimeout = NO;
}


- (void)resetSession
{
	CHECKQUEUE(_queue)
	
	[self resetAllOperations];
	if (_session)
	{
		[_session invalidateAndCancel];
		_session = nil;
	}
	_sessionTimeout = NO;
}


- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
	CHECKQUEUE(_queue)
	
	if (!error)
		return;
	
	DASSERT(session == _session);
	_session = nil;
	
	if (_sessionActive)
	{
		DASSERT(!_sessionTimeout);
		_sessionTimeout = YES;
		typeof(self) __weak weakSelf = self;
		[MBConnectService operation:_queue delay:1. block:^
		 {
			 typeof(self) strongSelf = weakSelf;
			 if (strongSelf)
			 {
				 if (strongSelf->_sessionTimeout)
					 [strongSelf startSession];
			 }
		 }];
	}
	
	[self stopAllOperations];
}


#pragma mark -
#pragma mark Connect


- (id<MBConnectOperation>)connectWithMethod:(NSString*)method function:(NSString*)function andParameters:(NSDictionary*)parameters
									 options:(MBConnectOptions)options completionHandler:(MBConnectCompletion)completionHandler
{
	NSURLRequest *request = [NSURLRequest MBAPIRequestWithMethod:method function:function andParameters:parameters timeoutInterval:kMBNetworkDefaultRequestTimeout];
	MBConnectOperation *operation = [[MBConnectOperation alloc] initWithQueue:_queue request:request options:options completionHandler:completionHandler];
	[MBConnectService operation:_queue delay:0. block:^
	 {
		 DASSERT(_sessionLaunched);
		 if (!_sessionLaunched)
		 {
			 [operation callCompletionWithResponse:nil error:[NSError MBMegaCancelledError]];
			 return;
		 }
		 [self scheduleOperation:operation];
	 }];
	return operation;
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)sessionTask didCompleteWithError:(NSError *)error
{
	CHECKQUEUE(_queue)
	
	if (session != _session)
		return;
	
	NSUInteger index = [_operations indexOfMBConnectOperationWithTask:(NSURLSessionDataTask*) sessionTask];
	if (index == NSNotFound)
		return;
	
	MBConnectOperation *operation = (MBConnectOperation*)[_operations objectAtIndex:index];
	DASSERT(!operation.queue_isCancelled);
	if (operation.queue_isCancelled)
		return;
	
	if (!error)
	{
		NSInteger statusCode = sessionTask.response ? ((NSHTTPURLResponse*) sessionTask.response).statusCode : 0;
		if (statusCode == 0 || !(200 <= statusCode && statusCode < 300))
			error = [NSError MBMegaInvalidHTTPResponseErrorWithStatusCode:statusCode];
	}
	id apiresponse = nil;
	NSError *apierror = nil;
	if (!error && operation.receivedDataStream)
	{
		[operation.receivedDataStream close];
		NSData *responseData = [operation.receivedDataStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
		if (responseData)
		{
			NSDictionary *response = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseData options:0 error:NULL];
			// apierror = [NSError MBAPIErrorFromMBAPIResponseDictionary:response];
			// Считаю что как-будто все ОК и всегда resultCode=OK, ошибки в ответе пока не обрабатываю (я даже не знаю пока их спецификации;-))
			apiresponse = [response objectForKey:@"payload"];
			DASSERT(apiresponse);
			NSNumber *computeResponseChecksum = operation.userInfo ? (NSNumber*)[operation.userInfo objectForKey:kMBConnectOperationComputeResponseChecksumKey] : nil;
			if (computeResponseChecksum && [computeResponseChecksum boolValue])
			{
				uint_least32_t apichecksum = [responseData MBAPIChecksum];
				NSMutableDictionary *userInfo = operation.userInfo ? [operation.userInfo mutableCopy] : [[NSMutableDictionary alloc] initWithCapacity:1];
				[userInfo setObject:[NSNumber numberWithInt:apichecksum] forKey:kMBConnectOperationResponseChecksumKey];
				operation.userInfo = userInfo;
			}
		}
	}
	
	if (error)
	{
		if (_sessionLaunched && operation.isPermanent)
		{
			[self stopOperation:operation];
			if (_sessionActive)
			{
				operation.taskTimeout = YES;
				typeof(self) __weak weakSelf = self;
				[MBConnectService operation:_queue delay:kMBNetworkRequestRepeatDelay block:^
				 {
					 typeof(self) strongSelf = weakSelf;
					 if (strongSelf)
					 {
						 if (operation.taskTimeout)
							 [strongSelf startOperation:operation];
					 }
				 }];
			}
			return;
		}
	}
	
	[self unscheduleOperation:operation];
	[operation callCompletionWithResponse:apiresponse error:error ?: apierror];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)sessionTask didReceiveData:(NSData *)data
{
	if (session != _session)
		return;
	
	NSUInteger index = [_operations indexOfMBConnectOperationWithTask:sessionTask];
	if (index == NSNotFound)
		return;
	MBConnectOperation *operation = (MBConnectOperation*)[_operations objectAtIndex:index];
	DASSERT(operation.receivedDataStream);
	if (operation.receivedDataStream && [operation.receivedDataStream hasSpaceAvailable])
		if (data)
			[data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop)
			 {
				 [operation.receivedDataStream write:bytes maxLength:byteRange.length];
			 }];
}


@end


NOTIFICATION_IMPL(MBConnectServiceDidChangeActiveNotification)

NSString *const kMBConnectOperationComputeResponseChecksumKey = @"MBConnectOperationComputeResponseChecksum";
NSString *const kMBConnectOperationResponseChecksumKey = @"MBConnectOperationResponseChecksumKey";

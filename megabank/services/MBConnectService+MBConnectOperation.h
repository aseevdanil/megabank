//
//  MBConnectService+MBConnectOperation.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBConnectService.h"



@interface MBConnectOperation : NSObject <MBConnectOperation>
{
	NSOperationQueue *_queue;
	NSURLRequest *_request;
	MBConnectOptions _options;
	MBConnectCompletion _completionHandler;
	NSURLSessionDataTask *_task;
	UIBackgroundTaskIdentifier _taskBackground;
	NSOutputStream *_receivedDataStream;
	UIBackgroundTaskIdentifier _extraBackground;
	NSDictionary *_userInfo;
	unsigned int _cancelled : 1;
	unsigned int _queue_cancelled : 1;
	unsigned int _taskTimeout : 1;
}

- (instancetype)initWithQueue:(NSOperationQueue*)queue request:(NSURLRequest*)request options:(MBConnectOptions)options completionHandler:(MBConnectCompletion)completionHandler;
@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, assign, readonly) MBConnectOptions options;
@property (nonatomic, copy, readonly) MBConnectCompletion completionHandler;

- (void)cancel;
@property (nonatomic, assign, readonly, getter = isCancelled) BOOL cancelled;	// KVO, thread-safing
@property (nonatomic, assign, readonly, getter = queue_isCancelled) BOOL queue_cancelled;	// KVO

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskBackground;
@property (nonatomic, assign) BOOL taskTimeout;
@property (nonatomic, strong) NSOutputStream *receivedDataStream;

@property (nonatomic, copy) NSDictionary *userInfo;

@end


@interface MBConnectOperation (MB)

@property (nonatomic, assign, readonly, getter = isPermanent) BOOL permanent;
- (void)callCompletionWithResponse:(id)response error:(NSError*)error;

@end


@interface NSArray (MBConnectOperation)

- (NSUInteger)indexOfMBConnectOperationWithTask:(NSURLSessionDataTask*)task;

@end



#pragma mark -


@interface MBConnectService (MBConnectOperation)

- (void)startOperation:(MBConnectOperation*)operation;
- (void)startAllOperations;
- (void)suspendOperation:(MBConnectOperation*)operation;
- (void)suspendAllOperations;
- (void)stopOperation:(MBConnectOperation*)operation;
- (void)stopAllOperations;

- (void)scheduleOperation:(MBConnectOperation*)operation;
- (void)unscheduleOperation:(MBConnectOperation*)operation;
- (void)resetAllOperations;

@end


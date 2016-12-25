//
//  MBDownloadSession+MBDownloadOperation.h
//  megabank
//
//  Created by da on 13.04.16.
//  Copyright © 2016 megabank. All rights reserved.
//

#import "MBDownloadSession.h"



#pragma mark MBDownloadOperation


@interface MBDownloadOperation : NSObject <MBOperation>
{
	NSOperationQueue *_queue;
	void (^_completionHandler)(NSURL *location, NSError *error);
	unsigned int _completed : 1;
}

- (instancetype)initWithQueue:(NSOperationQueue*)queue completion:(void(^)(NSURL *location, NSError *error))completionHandler;
@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, copy, readonly) void (^completionHandler)(NSURL *location, NSError *error);

@property (nonatomic, assign, getter = isCompleted) BOOL completed;

@end



#pragma mark MBDownloadTask


@interface MBDownloadTask : NSObject
{
	NSURL *_fileURL;
	NSURLSessionDownloadTask *_sessionTask;
	NSMutableArray *_operations;
	unsigned int _sessionTaskTimeout : 1;
}

- (instancetype)initWithFileURL:(NSURL*)fileURL;
@property (nonatomic, strong, readonly) NSURL *fileURL;

@property (nonatomic, strong) NSURLSessionDownloadTask *sessionTask;
@property (nonatomic, assign, getter = isSessionTaskTimeout) BOOL sessionTaskTimeout;

@property (nonatomic, strong, readonly) NSMutableArray *operations;

@end


@interface NSArray (MBDownloadTask)

- (NSUInteger)indexOfMBDownloadTaskWithFileURL:(NSURL*)fileURL;
- (NSUInteger)indexOfMBDownloadTaskWithSessionTask:(NSURLSessionTask*)sessionTask;

@end



#pragma mark -


@interface MBDownloadSession (MBDownloadOperation)

// All methods need call on Download queue
- (void)resumeTask:(MBDownloadTask*)task;
- (void)resumeAllTasks;
- (void)suspendTask:(MBDownloadTask*)task;
- (void)suspendAllTasks;
- (void)cancelTask:(MBDownloadTask*)task;
- (void)cancelAllTasks;
- (void)deallocAllTasks;

- (void)startOperation:(MBDownloadOperation*)operation withFileURL:(NSURL*)fileURL;
- (void)stopOperation:(MBDownloadOperation*)operation;

@end

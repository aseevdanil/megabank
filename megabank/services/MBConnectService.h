//
//  MBConnectService.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>



typedef NS_OPTIONS(NSUInteger, MBConnectOptions)
{
	MBConnectOptionNone						= 0,
	MBConnectOptionPermanently				= 1 << 0,	// Перманентное соединение не отключается, даже если приложение не активно
	MBConnectOptionCompletionOnMainQueue	= 1 << 1,	// completionHandler вызовется на main queue, иначе на внутреннем quqeue сервиса
};


@protocol MBConnectOperation <MBOperation>
@property (nonatomic, copy) NSDictionary *userInfo;
@end


typedef void (^MBConnectCompletion)(id<MBConnectOperation> connectOperation,id response, NSError *error);


@interface MBConnectService : NSObject <MBService>
{
	NSOperationQueue *_queue;
	NSURLSession *_session;
	NSMutableArray *_operations;
	
	unsigned int _launched : 1;
	unsigned int _active : 1;
	
	unsigned int _sessionLaunched : 1;
	unsigned int _sessionActive : 1;
	unsigned int _sessionTimeout : 1;
	
	unsigned int _reachabilityStatus : 2;
}

SINGLETON_DECL(sharedService)

// Connection active, if service launched, application is active and network is reachable
// For use in ui on main thread
@property (nonatomic, assign, readonly, getter = isActive) BOOL active;

- (id<MBConnectOperation>)connectWithMethod:(NSString*)method function:(NSString*)function andParameters:(NSDictionary*)parameters
									options:(MBConnectOptions)options completionHandler:(MBConnectCompletion)completionHandler;

@end


NOTIFICATION_DECL(MBConnectServiceDidChangeActiveNotification)	// On main thread


FOUNDATION_EXTERN NSString *const kMBConnectOperationComputeResponseChecksumKey;
FOUNDATION_EXTERN NSString *const kMBConnectOperationResponseChecksumKey;


#define MBCONNECTIONRELEASE(__connection)	if (__connection) { [__connection cancel]; __connection = nil; }

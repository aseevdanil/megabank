//
//  MBDef.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



//#define LOCAL(string)	[[NSBundle mainBundle] localizedStringForKey:string value:string table:nil]
#define LOCAL(string)	string


#define theApp ((MBApp*) [UIApplication sharedApplication].delegate)


#define kMBNetworkRequestNormalTimeout		10.
#define kMBNetworkRequestLongTimeout		20.
#define kMBNetworkRequestInfiniteTimeout	60.

#define kMBNetworkDefaultRequestTimeout		kMBNetworkRequestNormalTimeout
#define kMBNetworkDownloadRequestTimeout	kMBNetworkRequestNormalTimeout

#define kMBNetworkRequestRepeatDelay		5.


#define CHECKQUEUE(__queue)	DASSERT([NSOperationQueue currentQueue] == (__queue ?: [NSOperationQueue mainQueue]));
#define CHECKMAINQUEUE		CHECKQUEUE(nil)



// NSURLRequest HTTPMethods
static NSString *const GET		= @"GET";
static NSString *const HEAD		= @"HEAD";
static NSString *const DELETE	= @"DELETE";
static NSString *const POST		= @"POST";
static NSString *const PUT		= @"PUT";



///////////////////////////////////////////////////////////////////////////////////////////////////
// Singlton
#define SINGLETON_DECL(singleton) + (instancetype) singleton;
#define SINGLETON_IMPL(singleton)		\
+ (instancetype) singleton			\
{									\
static id Singletone = nil;	\
static dispatch_once_t once;	\
dispatch_once(&once, ^{ Singletone = [[self alloc] init]; });	\
return Singletone;				\
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Safe invocation
#define SAFE_CALL_WEAK_TARGET_METHOD(__weakMethodTarget, __methodSelector) \
{ \
id __strongMethodTarget = __weakMethodTarget; \
if (__strongMethodTarget && __methodSelector) \
((void (*)(id, SEL))[__strongMethodTarget methodForSelector:__methodSelector])(__strongMethodTarget, __methodSelector); \
}

#define SAFE_CALL_WEAK_TARGET_METHOD_WITH_OBJECT(__weakMethodTarget, __methodSelector, __methodObject) \
{ \
id __strongMethodTarget = __weakMethodTarget; \
if (__strongMethodTarget && __methodSelector) \
((void (*)(id, SEL, id))[__strongMethodTarget methodForSelector:__methodSelector])(__strongMethodTarget, __methodSelector, __methodObject); \
}

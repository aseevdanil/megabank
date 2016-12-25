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

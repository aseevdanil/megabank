//
//  DADef.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



///////////////////////////////////////////////////////////////////////////////////////////////////
// Flags
#define IS_FLAG(value, flag)		(((value) & (flag)) == (flag))
#define SET_FLAG(value, flag)		(value |= (flag))
#define RES_FLAG(value, flag)		(value &= ~(flag))
#define SWITCH_FLAG(value, flag)	(value = ((~value) & (flag)) | (value & ~(flag)))


///////////////////////////////////////////////////////////////////////////////////////////////////
// Fast Equals

// NSString
#define DA_EQUAL_STRINGS(__OBJ1,__OBJ2) (__OBJ1 == __OBJ2 || (__OBJ1 && [__OBJ1 isEqualToString:__OBJ2]))

// NSDate
#define DA_EQUAL_DATES(__OBJ1,__OBJ2) (__OBJ1 == __OBJ2 || (__OBJ1 && [__OBJ1 isEqualToDate:__OBJ2]))


///////////////////////////////////////////////////////////////////////////////////////////////////
// Time
#define DA_MINUTE 60.
#define DA_HOUR   (60 * DA_MINUTE)
#define DA_DAY    (24 * DA_HOUR)
#define DA_5_DAYS (5 * DA_DAY)
#define DA_WEEK   (7 * DA_DAY)
#define DA_MONTH  (30.5 * DA_DAY)
#define DA_YEAR   (365 * DA_DAY)


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


///////////////////////////////////////////////////////////////////////////////////////////////////
// Notification
#define NOTIFICATION_DECL(n) FOUNDATION_EXTERN NSString *const n;
#define NOTIFICATION_IMPL(n) NSString *const n = @#n;

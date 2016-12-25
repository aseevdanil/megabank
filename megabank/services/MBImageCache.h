//
//  MBImageCache.h
//  megabank
//
//  Created by da on 23.12.14.
//  Copyright (c) 2014 RBC. All rights reserved.
//



@interface MBImageCache : NSObject
{
	NSMutableDictionary *_memory;
	NSLock *_lock;
	NSString *_disk;
	
	NSTimeInterval _maxCacheAge;
	u_int64_t _maxCacheSize;
}

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCache:(NSString*)cachePath;
@property (nonatomic, copy, readonly) NSString *cachePath;

@property (nonatomic, assign) NSTimeInterval maxCacheAge;
@property (nonatomic, assign) u_int64_t maxCacheSize;
- (void)clear:(BOOL)onlyMemory;
- (void)clean;

- (void)storeImage:(UIImage*)image forKey:(NSString*)key toDisk:(BOOL)disk;
- (UIImage*)readImageForKey:(NSString*)key fromDisk:(BOOL)disk;

@end

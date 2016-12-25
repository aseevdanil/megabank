//
//  MBImageCache.m
//  megabank
//
//  Created by da on 23.12.14.
//  Copyright (c) 2014 RBC. All rights reserved.
//

#import "MBImageCache.h"



@implementation MBImageCache


@synthesize cachePath = _disk;
@synthesize maxCacheAge = _maxCacheAge, maxCacheSize = _maxCacheSize;


- (instancetype)initWithCache:(NSString*)cachePath
{
	if ((self = [super init]))
	{
		_maxCacheAge = 1 * DA_DAY;
		_maxCacheSize = 10 * 1024 * 1024;
		
		_memory = [[NSMutableDictionary alloc] init];
		_lock = [[NSLock alloc] init];
		_disk = [cachePath copy];
	}
	return self;
}


- (void)clear:(BOOL)onlyMemory
{
	[_lock lock];
	[_memory removeAllObjects];
	[_lock unlock];
	if (!onlyMemory)
		[[NSFileManager defaultManager] removeItemAtPath:_disk error:nil];
}


- (void)clean
{
	NSTimeInterval maxCacheAge = _maxCacheAge;
	u_int64_t maxCacheSize = _maxCacheSize;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *urlResourceKeys = [NSArray arrayWithObjects:NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey, nil];
	NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:_disk isDirectory:YES]
											 includingPropertiesForKeys:urlResourceKeys
																options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles
														   errorHandler:NULL];
	NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-maxCacheAge];
	NSMutableDictionary *cacheFiles = [[NSMutableDictionary alloc] init];
	u_int64_t currentCacheSize = 0;
	NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
	for (NSURL *fileURL in fileEnumerator)
	{
	   NSDictionary *resourceValues = [fileURL resourceValuesForKeys:urlResourceKeys error:NULL];
	   NSNumber *urlIsDirectory = (NSNumber*)[resourceValues objectForKey:NSURLIsDirectoryKey];
	   if (urlIsDirectory && [urlIsDirectory boolValue])
		   continue;
	   
	   NSDate *modificationDate = (NSDate*)[resourceValues objectForKey:NSURLContentModificationDateKey];
	   if ([modificationDate compare:expirationDate] != NSOrderedDescending)
	   {
		   [urlsToDelete addObject:fileURL];
		   continue;
	   }
	   
	   NSNumber *totalFileAllocatedSize = (NSNumber*)[resourceValues objectForKey:NSURLTotalFileAllocatedSizeKey];
	   currentCacheSize += totalFileAllocatedSize ? [totalFileAllocatedSize unsignedIntegerValue] : 0;
	   [cacheFiles setObject:resourceValues forKey:fileURL];
	}

	for (NSURL *fileURL in urlsToDelete)
	   [fileManager removeItemAtURL:fileURL error:nil];

	if (maxCacheSize > 0 && currentCacheSize > maxCacheSize)
	{
	   // Target half of our maximum cache size for this cleanup pass.
	   const u_int64_t desiredCacheSize = maxCacheSize / 2;
	   // Sort the remaining cache files by their last modification time (oldest first).
	   NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2)
							   {
								   NSDate *modificationDate1 = (NSDate*)[(NSDictionary*) obj1 objectForKey:NSURLContentModificationDateKey];
								   NSDate *modificationDate2 = (NSDate*)[(NSDictionary*) obj2 objectForKey:NSURLContentModificationDateKey];
								   return [modificationDate1 compare:modificationDate2];
							   }];
	   // Delete files until we fall below our desired cache size.
	   for (NSURL *fileURL in sortedFiles)
	   {
		   if ([fileManager removeItemAtURL:fileURL error:nil])
		   {
			   NSDictionary *resourceValues = (NSDictionary*)[cacheFiles objectForKey:fileURL];
			   NSNumber *totalFileAllocatedSize = (NSNumber*)[resourceValues objectForKey:NSURLTotalFileAllocatedSizeKey];
			   currentCacheSize -= totalFileAllocatedSize ? [totalFileAllocatedSize unsignedIntegerValue] : 0;
			   if (currentCacheSize < desiredCacheSize)
				   break;
		   }
	   }
	}
}


#pragma mark -
#pragma mark Images


- (NSString*)imageFilePathForKey:(NSString*)key
{
	DASSERT(key);
	return [_disk stringByAppendingPathComponent:key];
}


- (void)storeImage:(UIImage*)image forKey:(NSString*)key toDisk:(BOOL)disk
{
	if (!image || !key)
		return;
	
	[_lock lock];
	[_memory setObject:image forKey:key];
	[_lock unlock];
	
	if (disk)
	{
		NSData *imageData = nil;
		CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(image.CGImage);
		BOOL nonalpha = alphaInfo == kCGImageAlphaNone || alphaInfo == kCGImageAlphaNoneSkipFirst || alphaInfo == kCGImageAlphaNoneSkipLast;
		if (!nonalpha)
		{
			// png не хранит ориентацию, поэтому перегоняю в Up
			image = [image standardOrientedImage];
			imageData = UIImagePNGRepresentation(image);
		}
		else
		{
			imageData = UIImageJPEGRepresentation(image, 1.);
		}
		if (imageData)
		{
		   if (![[NSFileManager defaultManager] fileExistsAtPath:_disk])
			   [[NSFileManager defaultManager] createDirectoryAtPath:_disk withIntermediateDirectories:YES attributes:nil error:NULL];
		   [[NSFileManager defaultManager] createFileAtPath:[self imageFilePathForKey:key] contents:imageData attributes:nil];
		}
	}
}


- (UIImage*)readImageForKey:(NSString*)key fromDisk:(BOOL)disk
{
	UIImage *image = nil;
	
	[_lock lock];
	image = (UIImage*)[_memory objectForKey:key];
	[_lock unlock];
	if (image)
		return image;
	
	if (disk)
	{
		NSString *filePath = [self imageFilePathForKey:key];
		NSData *data = [NSData dataWithContentsOfFile:filePath];
		image = data ? [UIImage imageWithData:data scale:UIScreenScale()] : nil;
		if (image)
		{
			[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate] ofItemAtPath:filePath error:NULL];
			[_lock lock];
			[_memory setObject:image forKey:key];
			[_lock unlock];
		}
	}
	return image;
}


@end

//
//  NSManagedObject+MB.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "NSManagedObject+MB.h"



@implementation NSManagedObject (MB)


+ (id)MB_createInContext:(NSManagedObjectContext*)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
}


- (void)MB_deleteInContext:(NSManagedObjectContext*)context
{
	[context deleteObject:self];
}


+ (void)MB_deleteWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MB_requestWithPredicate:predicate inContext:context];
	request.includesPropertyValues = NO;
	request.returnsObjectsAsFaults = YES;
	NSArray *objects = [request MB_requestedAllInContext:context];
	for (NSManagedObject *object in objects)
		[context deleteObject:object];
}


+ (void)MB_deleteAllInContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MB_requestInContext:context];
	request.includesPropertyValues = NO;
	request.returnsObjectsAsFaults = YES;
	NSArray *objects = [request MB_requestedAllInContext:context];
	for (NSManagedObject *object in objects)
		[context deleteObject:object];
}


@end



@implementation NSManagedObject (MB_request)


+ (NSFetchRequest*)MB_requestInContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:context]];
	return request;
}


+ (NSFetchRequest*)MB_requestWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MB_requestInContext:context];
	[request setPredicate:searchTerm];
	return request;
}


+ (NSFetchRequest*)MB_requestForProperty:(NSString *)property withValue:(id)value inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MB_requestInContext:context];
	[request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", property, value]];
	return request;
}


+ (NSFetchRequest*)MB_requestSortedBy:(NSArray<NSString*>*)sortKeys ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MB_requestWithPredicate:searchTerm inContext:context];
	NSMutableArray* sortDescriptors = [[NSMutableArray alloc] initWithCapacity:sortKeys.count];
	for (NSString* sortKey in sortKeys)
		[sortDescriptors addObject:[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending]];
	[request setSortDescriptors:sortDescriptors];
	return request;
}


@end



@implementation NSManagedObject (MB_find)


+ (NSArray*)MB_findAllInContext:(NSManagedObjectContext *)context
{
	return [[self MB_requestInContext:context] MB_requestedAllInContext:context];
}


+ (NSArray*)MB_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	return [[self MB_requestWithPredicate:searchTerm inContext:context] MB_requestedAllInContext:context];
}


+ (NSArray*)MB_findAllForProperty:(NSString *)property withValue:(id)value inContext:(NSManagedObjectContext *)context
{
	return [[self MB_requestForProperty:property withValue:value inContext:context] MB_requestedAllInContext:context];
}


+ (NSArray*)MB_findAllSortedBy:(NSArray<NSString*>*)sortKeys ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	return [[self MB_requestSortedBy:sortKeys ascending:ascending withPredicate:searchTerm inContext:context] MB_requestedAllInContext:context];
}


+ (id)MB_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	return [[self MB_requestWithPredicate:searchTerm inContext:context] MB_requestedFirstInContext:context];
}


+ (id)MB_findFirstForProperty:(NSString *)property withValue:(id)value inContext:(NSManagedObjectContext *)context
{
	return [[self MB_requestForProperty:property withValue:value inContext:context] MB_requestedFirstInContext:context];
}


+ (id)MB_findFirstSortedBy:(NSArray<NSString*>*)sortKeys ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	return [[self MB_requestSortedBy:sortKeys ascending:ascending withPredicate:searchTerm inContext:context] MB_requestedFirstInContext:context];
}


@end



@implementation NSManagedObject (MB_fetch)


+ (NSFetchedResultsController*)MB_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray<NSString*>*)sortKeys ascending:(BOOL)ascending delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MB_requestSortedBy:sortKeys ascending:ascending withPredicate:searchTerm inContext:context];
	NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:group cacheName:nil];
	controller.delegate = delegate;
	[controller performFetch:NULL];
	return controller;
}


@end



@implementation NSManagedObject (MB_aggregation)


+ (NSUInteger)MB_aggregationCountOfEntitiesWithPredicate:(NSPredicate *)searchFilter inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MB_requestWithPredicate:searchFilter inContext:context];
	request.resultType = NSManagedObjectIDResultType;
	request.includesPropertyValues = NO;
	return [context countForFetchRequest:request error:NULL];
}


+ (BOOL)MB_aggregationIsExistEntitiesWithPredicate:(NSPredicate *)searchFilter inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MB_requestWithPredicate:searchFilter inContext:context];
	request.resultType = NSManagedObjectIDResultType;
	request.includesPropertyValues = NO;
	[request setFetchLimit:1];
	return [context countForFetchRequest:request error:NULL] > 0;
}


@end



@implementation NSFetchRequest (MB)


- (void)handleError:(NSError*)error
{
	DPRINT(@"MB_request Error Message: %@", [error localizedDescription]);
}


- (NSUInteger)MB_fetchedCountInContext:(NSManagedObjectContext*)context
{
	NSError *error = nil;
	NSUInteger count = [context countForFetchRequest:self error:&error];
	if (error)
		[self handleError:error];
	return count;
}


- (NSArray*)MB_requestedAllInContext:(NSManagedObjectContext*)context
{
	NSError *error = nil;
	NSArray *results = [context executeFetchRequest:self error:&error];
	if (error)
		[self handleError:error];
	return results;
}


- (id)MB_requestedFirstInContext:(NSManagedObjectContext*)context
{
	[self setFetchLimit:1];
	NSArray *results = [self MB_requestedAllInContext:context];
	if (results && [results count] > 0)
		return [results objectAtIndex:0];
	return nil;
}


@end

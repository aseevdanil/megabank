//
//  NSManagedObject+MB.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import <CoreData/CoreData.h>



@interface NSManagedObject (MB)

+ (id)MB_createInContext:(NSManagedObjectContext*)context;
- (void)MB_deleteInContext:(NSManagedObjectContext*)context;
+ (void)MB_deleteAllInContext:(NSManagedObjectContext *)context;
+ (void)MB_deleteWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

@end



@interface NSManagedObject (MB_request)

+ (NSFetchRequest*)MB_requestInContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest*)MB_requestWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest*)MB_requestForProperty:(NSString *)property withValue:(id)value inContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest*)MB_requestSortedBy:(NSArray<NSString*>*)sortKeys ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

@end


@interface NSManagedObject (MB_find)

+ (NSArray*)MB_findAllInContext:(NSManagedObjectContext *)context;
+ (NSArray*)MB_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (NSArray*)MB_findAllForProperty:(NSString *)property withValue:(id)value inContext:(NSManagedObjectContext *)context;
+ (NSArray*)MB_findAllSortedBy:(NSArray<NSString*>*)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (id)MB_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (id)MB_findFirstForProperty:(NSString *)property withValue:(id)value inContext:(NSManagedObjectContext *)context;
+ (id)MB_findFirstSortedBy:(NSArray<NSString*>*)sortKeys ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

@end


@interface NSManagedObject (MB_fetch)

+ (NSFetchedResultsController*)MB_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray<NSString*>*)sortKeys ascending:(BOOL)ascending delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context;

@end


@interface NSManagedObject (MB_aggregation)

+ (NSUInteger)MB_aggregationCountOfEntitiesWithPredicate:(NSPredicate *)searchFilter inContext:(NSManagedObjectContext *)context;
+ (BOOL)MB_aggregationIsExistEntitiesWithPredicate:(NSPredicate *)searchFilter inContext:(NSManagedObjectContext *)context;

@end



@interface NSFetchRequest (MB)

- (NSUInteger)MB_fetchedCountInContext:(NSManagedObjectContext*)context;
- (NSArray*)MB_requestedAllInContext:(NSManagedObjectContext*)context;
- (id)MB_requestedFirstInContext:(NSManagedObjectContext*)context;

@end


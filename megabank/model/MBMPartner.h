//
//  MBMPartner.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBMPartner : NSManagedObject <MBObject>

@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *logo;
@property (nonatomic, copy, readonly) NSURL *logoURL;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSSet *points;

@end


@interface MBMPartner (CoreDataGeneratedAccessors)

- (void)addPointsObject:(NSManagedObject *)value;
- (void)removePointsObject:(NSManagedObject *)value;
- (void)addPoints:(NSSet *)values;
- (void)removePoints:(NSSet *)values;

@end



@interface MBMPartner (MBAPIMappable) <MBAPIMappable>
@end



@interface MBMPartner (MB)

+ (MBMPartner*)MBPartnerWithPid:(NSString*)pid inContext:(NSManagedObjectContext*)context;
+ (MBMPartner*)MBCreatePartnerWithPid:(NSString*)pid inContext:(NSManagedObjectContext *)context;
+ (MBMPartner*)MBPreparePartnerWithPid:(NSString*)pid inContext:(NSManagedObjectContext*)context;

@end

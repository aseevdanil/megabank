//
//  MBMPoint.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBMPoint : NSManagedObject

@property (nonatomic, strong) MBMPartner *partner;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *schedule;

@end



@interface MBMPoint (MBAPIMappable) <MBAPIMappable>
@end



@interface MBMPoint (MB)

+ (MBMPoint*)MBPreparePartnerPoint:(MBMPartner*)partner withLocation:(CLLocationCoordinate2D)pointLocation inContext:(NSManagedObjectContext*)context;

@end

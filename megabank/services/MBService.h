//
//  MBService.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



// Сервисы управляются App через интерфейс MBService на main thread
@protocol MBService
- (void)launch;
- (void)stop;
@property (nonatomic, assign, readonly, getter = isLaunched) BOOL launched;
@end



#import "MBConnectService.h"
#import "MBLocationService.h"
#import "MBPartnersService.h"
#import "MBImagesService.h"

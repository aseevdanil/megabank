//
//  MBPartnersService.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBPartnersService : NSObject <MBService>
{
	unsigned int _launched : 1;
	unsigned int _partnersLoaded : 1;
}

SINGLETON_DECL(sharedService)

@property (nonatomic, assign, readonly, getter = isPartnersLoaded) BOOL partnersLoaded;

@end


NOTIFICATION_DECL(MBPartnersServicePartnersLoadedDidChangeNotification)

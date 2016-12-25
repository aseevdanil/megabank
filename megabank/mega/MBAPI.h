//
//  MBAPI.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



#define kMBURL				@"https://api.tinkoff.ru/v1"

#define MBAPIStringEncoding	NSUTF8StringEncoding



#define kMBAPI_Pertners		@"deposition_partners"
#define kMBAPI_Points		@"deposition_points"



@interface NSURL (MBAPI)

+ (NSURL*)MBAPIURL;
+ (NSURL*)MBAPIURLWithFunction:(NSString*)function;
+ (NSURL*)MBAPIURLWithFunction:(NSString*)function andParameters:(NSDictionary*)parameters;

@end


@interface NSURLRequest (MBAPI)

+ (NSURLRequest*)MBAPIRequestWithMethod:(NSString*)method function:(NSString*)function andParameters:(NSDictionary*)parameters timeoutInterval:(NSTimeInterval)timeoutInterval;

@end



#pragma mark Helpers


@interface NSData (MBAPI)

- (uint_least32_t)MBAPIChecksum;

@end


//
//  MBAPI.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBAPI.h"



@implementation NSURL (MBAPI)


+ (NSURL*)MBAPIURL
{
	return [self MBAPIURLWithFunction:nil andParameters:nil];
}


+ (NSURL*)MBAPIURLWithFunction:(NSString*)function
{
	return [self MBAPIURLWithFunction:function andParameters:nil];
}


+ (NSURL*)MBAPIURLWithFunction:(NSString*)function andParameters:(NSDictionary*)parameters
{
	NSString *query = QueryString(parameters, MBAPIStringEncoding);
	if (query)
		return function ? [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@", kMBURL, function, query]] : [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", kMBURL, query]];
	else
		return function ? [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kMBURL, function]] : [NSURL URLWithString:[NSString stringWithFormat:@"%@", kMBURL]];
}


@end



@implementation NSURLRequest (MBAPIRequest)


+ (NSURLRequest*)MBAPIRequestWithMethod:(NSString*)method function:(NSString*)function andParameters:(NSDictionary*)parameters timeoutInterval:(NSTimeInterval)timeoutInterval
{
	NSMutableURLRequest *request = nil;
	if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"])
	{
		request = [[NSMutableURLRequest alloc] initWithURL:[NSURL MBAPIURLWithFunction:function andParameters:parameters]];
	}
	else
	{
		request = [[NSMutableURLRequest alloc] initWithURL:[NSURL MBAPIURLWithFunction:function andParameters:nil]];
		[request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(MBAPIStringEncoding))] forHTTPHeaderField:@"Content-Type"];
		if (parameters)
			[request setHTTPBody:[QueryString(parameters, MBAPIStringEncoding) dataUsingEncoding:MBAPIStringEncoding]];
	}
	[request setHTTPMethod:method];
	if (timeoutInterval)
		request.timeoutInterval = timeoutInterval;
	return request;
}


@end



#pragma mark NS+MBAPI


static uint_least32_t crc32(const char *buf, size_t len)
{
	/*
	 Name  : CRC-32
	 Poly  : 0x04C11DB7    x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11
	 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
	 Init  : 0xFFFFFFFF
	 Revert: true
	 XorOut: 0xFFFFFFFF
	 Check : 0xCBF43926 ("123456789")
	 MaxLen: 268 435 455 байт (2 147 483 647 бит) - обнаружение
	 одинарных, двойных, пакетных и всех нечетных ошибок
	 */
	
	uint_least32_t crc_table[256];
	uint_least32_t crc; int i, j;
	
	for (i = 0; i < 256; i++)
	{
		crc = i;
		for (j = 0; j < 8; j++)
			crc = crc & 1 ? (crc >> 1) ^ 0xEDB88320UL : crc >> 1;
		
		crc_table[i] = crc;
	};
	
	crc = 0xFFFFFFFFUL;
	
	while (len--)
		crc = crc_table[(crc ^ *buf++) & 0xFF] ^ (crc >> 8);
	
	return crc ^ 0xFFFFFFFFUL;
}


@implementation NSData (MBAPI)


- (uint_least32_t)MBAPIChecksum
{
	return crc32([self bytes], [self length]);
}


@end

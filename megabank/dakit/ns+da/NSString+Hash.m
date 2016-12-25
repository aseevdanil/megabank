//
//  NSString+Hash.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "NSString+Hash.h"

#import "NSData+Hash.h"



@implementation NSString (Hash)


- (NSString*)MD5Hash
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] MD5Hash];
}


@end

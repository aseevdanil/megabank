//
//  UIAlertController+MBMPoint.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "UIAlertController+MBMPoint.h"



@implementation UIAlertController (MBMPoint)


+ (instancetype)alertControllerForPoint:(MBMPoint*)point
{
	DASSERT(point);
	NSString *address = point.address, *schedule = point.schedule;
	NSMutableString *description = [[NSMutableString alloc] init];
	if (address && address.length > 0)
	{
		[description appendFormat:LOCAL(@"Адрес: %@"), address];
	}
	if (schedule && schedule.length > 0)
	{
		if (description.length > 0)
			[description appendString:@"\n"];
		[description appendFormat:LOCAL(@"Часы работы: %@"), schedule];
	}
	NSURL *URL = point.partner.url ? [NSURL URLWithString:point.partner.url] : nil;
	UIAlertController *alert = [self alertControllerWithTitle:point.partner.name message:description preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:LOCAL(@"Ok") style:UIAlertActionStyleCancel handler:nil]];
	if (URL)
		[alert addAction:[UIAlertAction actionWithTitle:LOCAL(@"Перейти") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
						  {
							  [[UIApplication sharedApplication] openURL:URL options:[NSDictionary dictionary] completionHandler:nil];
						  }]];
	return alert;
}


@end

//
//  MBBackgroundView.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBBackgroundView.h"



@implementation MBBackgroundView


- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.opaque = YES;
		self.backgroundColor = [UIColor MBBackgroundColor];
	}
	return self;
}


@end

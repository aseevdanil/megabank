//
//  MBViewController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBViewController.h"



@interface MBViewController ()
{
	unsigned int _withoutBackground : 1;
}

@end


@implementation MBViewController


- (instancetype)init
{
	if ((self = [super init]))
	{
		_withoutBackground = NO;
		self.anchorInsetsMaskAlpha = kMBViewController_AnchorInsetsMaskAlpha;
	}
	return self;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
	return MBStatusBarStyle;
}


- (void)loadBackgroundView
{
	if (!_withoutBackground)
		self.backgroundView = [[MBBackgroundView alloc] init];
}


- (BOOL)isWithoutBackground
{
	return _withoutBackground;
}


- (void)setWithoutBackground:(BOOL)withoutBackground
{
	if (withoutBackground == _withoutBackground)
		return;
	_withoutBackground = withoutBackground;
	[self reloadBackgroundView];
}


@end

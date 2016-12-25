//
//  MBWireframeController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBWireframeController.h"



#pragma mark MBMainController


@interface MBMainController : DAMainController

@end


@implementation MBMainController


@end



#pragma mark -


@interface MBWireframeController ()

@end


@implementation MBWireframeController


- (instancetype)init
{
	if ((self = [super init]))
	{
		self.backgroundViewController = [[MBViewController alloc] init];
		self.mainViewController = [[MBMainController alloc] init];
	}
	return self;
}


- (UIViewController<MBViewController>*)sceneViewController
{
	return (UIViewController<MBViewController>*) ((MBMainController*) self.mainViewController).sceneViewController;
}


- (void)setSceneViewController:(UIViewController<MBViewController>*)sceneViewController
{
	[self setSceneViewController:sceneViewController animated:NO completion:nil];
}


- (void)setSceneViewController:(UIViewController<MBViewController>*)sceneViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
	[(MBMainController*) self.mainViewController setSceneViewController:sceneViewController animated:animated completion:completion];
}


@end

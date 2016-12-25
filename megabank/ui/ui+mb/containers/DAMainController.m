//
//  DAMainController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "DAMainController.h"



@interface DAMainController ()
{
	UIViewController *_sceneViewController;
}

@end


@implementation DAMainController


@synthesize sceneViewController = _sceneViewController;


- (instancetype)init
{
	if ((self = [super init]))
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (void)didReceiveMemoryWarning
{
	BOOL clearView = [self isViewLoaded] && !self.view.window && !self.presentedViewController && !self.presentingViewController;
	if (clearView)
		[self viewWillClear];
	
	[super didReceiveMemoryWarning];
	
	if ([self isViewLoaded] && !self.view.window)
		self.view = nil;
	
	if (clearView)
		[self viewDidClear];
}


- (void)applicationDidEnterBackground:(NSNotification*)notification
{
	BOOL clearView = [self isViewLoaded] && !self.view.window && !self.presentedViewController && !self.presentingViewController;
	if (clearView)
	{
		[self viewWillClear];
		self.view = nil;
		[self viewDidClear];
	}
}


- (BOOL)shouldAutorotate
{
	return _sceneViewController && [_sceneViewController shouldAutorotate];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return _sceneViewController ? [_sceneViewController supportedInterfaceOrientations] : UIInterfaceOrientationMaskPortrait;
}


- (UIViewController *)childViewControllerForStatusBarHidden
{
	return _sceneViewController ?: [super childViewControllerForStatusBarHidden];
}


- (UIViewController *)childViewControllerForStatusBarStyle
{
	return _sceneViewController ?: [super childViewControllerForStatusBarStyle];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_sceneViewController.view.frame = self.view.bounds;
	_sceneViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_sceneViewController.view];
}


- (void)setSceneViewController:(UIViewController *)sceneViewController
{
	[self setSceneViewController:sceneViewController animated:NO completion:nil];
}


- (void)setSceneViewController:(UIViewController *)sceneViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion
{
#define kDAMainController_SceneViewControllerTransitionDuration .2
	if (sceneViewController == _sceneViewController)
	{
		if (completion)
			completion(YES);
		return;
	}
	UIViewController *oldSceneViewController = _sceneViewController;
	UIViewController *newSceneViewController = sceneViewController;
	if (oldSceneViewController == nil)
	{
		[self addChildViewController:newSceneViewController];
		_sceneViewController = sceneViewController;
		if ([self isViewLoaded])
		{
			newSceneViewController.view.frame = self.view.bounds;
			newSceneViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self.view addSubview:newSceneViewController.view];
		}
		[newSceneViewController didMoveToParentViewController:self];
		if (completion)
			completion(YES);
	}
	else if (newSceneViewController == nil)
	{
		[oldSceneViewController willMoveToParentViewController:nil];
		_sceneViewController = nil;
		if ([self isViewLoaded])
		{
			[oldSceneViewController.view removeFromSuperview];
		}
		[oldSceneViewController removeFromParentViewController];
		if (completion)
			completion(YES);
	}
	else
	{
		[oldSceneViewController willMoveToParentViewController:nil];
		[self addChildViewController:newSceneViewController];
		_sceneViewController = sceneViewController;
		if ([self isViewLoaded])
		{
			newSceneViewController.view.frame = self.view.bounds;
			newSceneViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		}
		void(^transitionCompletion)(BOOL finished) = ^(BOOL finished)
		{
			[oldSceneViewController removeFromParentViewController];
			[newSceneViewController didMoveToParentViewController:self];
			if (completion)
				completion(finished);
		};
		[self transitionFromViewController:oldSceneViewController toViewController:newSceneViewController
								  duration:animated && [self isViewLoaded] ? kDAMainController_SceneViewControllerTransitionDuration : 0. options:UIViewAnimationOptionTransitionCrossDissolve
								animations:nil completion:transitionCompletion];
	}
	[self setNeedsStatusBarAppearanceUpdate];
}


@end

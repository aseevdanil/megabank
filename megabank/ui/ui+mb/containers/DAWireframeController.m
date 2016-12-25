//
//  DAWireframeController.m
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "DAWireframeController.h"



@interface DAWireframeController ()
{
	UIViewController *_backgroundViewController;
	UIViewController *_mainViewController;
	
	UIView *_mainContainerView;
}

@end


@implementation DAWireframeController


@synthesize backgroundViewController = _backgroundViewController, mainViewController = _mainViewController;


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
	return _mainViewController && [_mainViewController shouldAutorotate];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return _mainViewController ? [_mainViewController supportedInterfaceOrientations] : UIInterfaceOrientationMaskPortrait;
}


- (UIViewController *)childViewControllerForStatusBarHidden
{
	return _mainViewController ?: [super childViewControllerForStatusBarHidden];
}


- (UIViewController *)childViewControllerForStatusBarStyle
{
	return _mainViewController ?: [super childViewControllerForStatusBarStyle];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	CGRect bounds = self.view.bounds;
	if (_backgroundViewController)
	{
		_backgroundViewController.view.frame = bounds;
		_backgroundViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:_backgroundViewController.view];
	}
	
	_mainContainerView = [[UIView alloc] initWithFrame:bounds];
	_mainContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_mainContainerView.opaque = NO;
	_mainContainerView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_mainContainerView];
	
	if (_mainViewController)
	{
		_mainViewController.view.frame = _mainContainerView.bounds;
		_mainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_mainContainerView addSubview:_mainViewController.view];
	}
}


- (void)viewDidClear
{
	[super viewDidClear];
	_mainContainerView = nil;
}


- (void)setBackgroundViewController:(UIViewController *)backgroundViewController
{
	if (backgroundViewController == _backgroundViewController)
		return;
	UIViewController *oldBackgroundViewController = _backgroundViewController;
	UIViewController *newBackgroundViewController = backgroundViewController;
	if (oldBackgroundViewController == nil)
	{
		[self addChildViewController:newBackgroundViewController];
		_backgroundViewController = backgroundViewController;
		if ([self isViewLoaded])
		{
			newBackgroundViewController.view.frame = self.view.bounds;
			newBackgroundViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self.view insertSubview:newBackgroundViewController.view atIndex:0];
		}
		[newBackgroundViewController didMoveToParentViewController:self];
	}
	else if (newBackgroundViewController == nil)
	{
		[oldBackgroundViewController willMoveToParentViewController:nil];
		_backgroundViewController = nil;
		if ([self isViewLoaded])
			[oldBackgroundViewController.view removeFromSuperview];
		[oldBackgroundViewController removeFromParentViewController];
	}
	else
	{
		[oldBackgroundViewController willMoveToParentViewController:nil];
		_backgroundViewController = nil;
		[self addChildViewController:newBackgroundViewController];
		_backgroundViewController = backgroundViewController;
		if ([self isViewLoaded])
		{
			newBackgroundViewController.view.frame = self.view.bounds;
			newBackgroundViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		}
		void (^transitionCompletion)(BOOL finished) = ^(BOOL finished)
		{
			[oldBackgroundViewController removeFromParentViewController];
			[newBackgroundViewController didMoveToParentViewController:self];
		};
		[self transitionFromViewController:oldBackgroundViewController toViewController:newBackgroundViewController
								  duration:0. options:UIViewAnimationOptionTransitionNone
								animations:nil completion:transitionCompletion];
	}
}


- (void)setMainViewController:(UIViewController *)mainViewController
{
	if (mainViewController == _mainViewController)
		return;
	UIViewController *oldMainViewController = _mainViewController;
	UIViewController *newMainViewController = mainViewController;
	if (oldMainViewController == nil)
	{
		[self addChildViewController:newMainViewController];
		_mainViewController = mainViewController;
		if ([self isViewLoaded])
		{
			newMainViewController.view.frame = _mainContainerView.bounds;
			newMainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[_mainContainerView addSubview:newMainViewController.view];
		}
		[newMainViewController didMoveToParentViewController:self];
	}
	else if (newMainViewController == nil)
	{
		[oldMainViewController willMoveToParentViewController:nil];
		_mainViewController = nil;
		if ([self isViewLoaded])
		{
			[oldMainViewController.view removeFromSuperview];
		}
		[oldMainViewController removeFromParentViewController];
	}
	else
	{
		[oldMainViewController willMoveToParentViewController:nil];
		[self addChildViewController:newMainViewController];
		_mainViewController = mainViewController;
		if ([self isViewLoaded])
		{
			newMainViewController.view.frame = _mainContainerView.bounds;
			newMainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		}
		void(^transitionCompletion)(BOOL finished) = ^(BOOL finished)
		{
			[oldMainViewController removeFromParentViewController];
			[newMainViewController didMoveToParentViewController:self];
		};
		[self transitionFromViewController:oldMainViewController toViewController:newMainViewController
								  duration:0. options:0
								animations:nil completion:transitionCompletion];
	}
	[self setNeedsStatusBarAppearanceUpdate];
}


@end

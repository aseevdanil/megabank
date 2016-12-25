//
//  DAViewController.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DAViewController : UIViewController

// BackgroundView exists only when view is loaded
@property (nonatomic, strong) UIView *backgroundView;	// use setter only in loadBackgroundView
- (void)reloadBackgroundView;
- (void)loadBackgroundView;								// Overload

// AnchorView exists only when view is loaded
// Please put your content views to anchorView
@property (nonatomic, strong, readonly) UIView *anchorView;
- (void)anchorViewDidLayoutSubviews;					// Overload
@property (nonatomic, assign, readonly) UIEdgeInsets anchorViewInsets;

@property (nonatomic, assign) CGFloat anchorInsetsMaskAlpha;

@property (nonatomic, strong, readonly) UIView *contentView;
- (void)contentViewDidLayoutSubviews;

@end

//
//  DAMainController.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DAMainController : UIViewController

@property (nonatomic, strong) UIViewController *sceneViewController;
- (void)setSceneViewController:(UIViewController *)sceneViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;

@end

//
//  UIViewController+DA.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UIViewController (DA)

- (void)reloadView;
- (void)clearView:(BOOL)clearChildsHierarchy;
- (BOOL)isViewVisible;
- (void)viewWillClear;
- (void)viewDidClear;

@end

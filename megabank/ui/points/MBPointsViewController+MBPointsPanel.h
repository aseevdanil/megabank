//
//  MBPointsViewController+MBPointsPanel.h
//  megabank
//
//  Created by da on 04.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//

#import "MBPointsViewController.h"

#import "MBPoints.h"

#import "MBPointsPanel.h"



@interface MBPointsViewController (MBPointsPanel) <MBPointsPanelDataSource, MBPointsPanelDelegate>

- (void)presentPointsPanel:(BOOL)animation;
- (void)dismissPointsPanel:(BOOL)animated;

- (void)setNeedsUpdatePointsPanel;
- (void)resetNeedsUpdatePointsPanel;
- (void)updatePointsPanel;

@end

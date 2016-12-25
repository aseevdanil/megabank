//
//  MBPointsPanel.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@protocol MBPointsPanelDataSource, MBPointsPanelDelegate;


@interface MBPointsPanel : MBView
{
	UIView *_backgroundView;
	UIView *_panelBaseView;
	UICollectionView *_contentView;
	CGRect _panelAnchorRect;
	UIInterpolatingMotionEffect *_panelVerticalMotionEffect, *_panelHorizontalMotionEffect;
	
	UIGestureRecognizer *_dismissGestureRecognizer;
	
	id<MBPointsPanelDataSource> __weak _pointsPanelDataSource;
	id<MBPointsPanelDelegate> __weak _pointsPanelDelegate;
	
	unsigned int _presented : 1;
}

- (void)reloadData;

- (void)presentPanelFromAnchorRect:(CGRect)anchorRect animated:(BOOL)animated completion:(void(^)(void))completionHandler;
- (void)dismissPanel:(BOOL)animated completion:(void(^)(void))completionHandler;
- (void)repositionWithAnchorRect:(CGRect)anchorRect;
@property (nonatomic, assign, readonly, getter = isPresented) BOOL presented;

@property (nonatomic, weak) id<MBPointsPanelDataSource> pointsPanelDataSource;
@property (nonatomic, weak) id<MBPointsPanelDelegate> pointsPanelDelegate;

@end


@protocol MBPointsPanelDataSource

- (NSUInteger)pointsPanelNumberOfPoints:(MBPointsPanel*)pointsPanel;
- (NSURL*)pointsPanel:(MBPointsPanel*)pointsPanel pointURLAtIndex:(NSUInteger)pointIndex;

@end


@protocol MBPointsPanelDelegate

- (void)pointsPanel:(MBPointsPanel*)pointsPanel didSelectPointAtIndex:(NSUInteger)avatarIndex;

- (BOOL)pointsPanelShouldDismissPanel:(MBPointsPanel*)pointsPanel;
- (void)pointsPanelDidDismissPanel:(MBPointsPanel*)pointsPanel;

@end

//
//  MBWireframeController.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



@interface MBWireframeController : DAWireframeController

@property (nonatomic, strong) UIViewController<MBViewController> *sceneViewController;
- (void)setSceneViewController:(UIViewController<MBViewController>*)sceneViewController animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;

@end

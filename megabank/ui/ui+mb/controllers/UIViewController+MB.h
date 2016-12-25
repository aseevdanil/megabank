//
//  UIViewController+MB.h
//  megabank
//
//  Created by da on 03.12.16.
//  Copyright © 2016 Aseev Danil. All rights reserved.
//



#define kMBViewController_AnchorInsetsMaskAlpha	.1



@protocol MBViewControllerWithBackground
@property (nonatomic, assign, getter = isWithoutBackground) BOOL withoutBackground;
@end


@protocol MBViewController <MBViewControllerWithBackground>
@end
